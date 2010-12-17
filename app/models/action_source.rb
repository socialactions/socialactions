class ActionSource < ActiveRecord::Base
  
  belongs_to :site
  belongs_to :action_type
  has_many :actions
  
  validates_presence_of :plugin_name
  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :site_id
  validates_presence_of :action_type_id
  validates_format_of :url, :with => /^([^\.\\\/].*\.csv|(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)$/ix,
                      :message => " is invalid, check format"
  after_save :check_site
  
  def after_initialize
    if !self.plugin_name.nil? && !self.plugin_name.blank?
      self.require "#{RAILS_ROOT}/lib/action_source_plugins/#{self.plugin_name}"
      self.extend Module.const_get(self.plugin_name.camelcase)
    end
  end
  
  def json_additional_data
    @json_additional_data ||= (ActiveSupport::JSON.decode(self.additional_data || "") || {})
  end
  
  def donations?
    json_additional_data['donations'] || false
  end
  
  def disabled=(bit)
    write_attribute(:disabled, bit)
    self.save
    self.actions.each do |action|
      action.disabled = bit
      action.save
    end
  end
  
  def fetch(furl, depth=0)
    uri = URI.parse(furl)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.get(uri.request_uri, 'User-Agent' => 'SocialActions')

    if res.is_a?(Net::HTTPRedirection)
      raise "redirect loop" if depth > 5

      if res.is_a?(Net::HTTPMovedPermanently)
        warn "301 Permanent Redirect for #{name} to #{res.header['location']} - updating db" 
        self.update_attribute(:url, res.header['location'])
      end

      return fetch(res.header['location'], depth+1)
    end

    unless res.is_a? Net::HTTPSuccess
      raise "#{res.code} #{res.message}"
    end

    res
  end
  
  def check_site
    self.site.ensure_state
  end
  
  def self.scrape(options = {})
    conditions = options[:all] ? nil : ['needs_updating = 1']
    find(:all, :conditions => conditions).each do |action_source|
      next if action_source.disabled
      puts "Parsing #{action_source.name}" if options[:debug]
      begin
        action_source.parse
      rescue Exception, RuntimeError, Timeout::Error
        puts "ERROR on action source #{action_source.name}: #{$!}"
      end
    end
  end
  
  def self.array_of_plugin_name_arrays
    dir = Dir.open "#{RAILS_ROOT}/lib/action_source_plugins"
    plugin_name_arrays = []
    dir.entries.each do |entry|
      unless !entry.grep(/^\./).empty?
        plugin_name_arrays << [entry.gsub(/\.rb$/,'')]
      end
    end
    plugin_name_arrays
  end
  
  def self.find_all_as_id_array
    action_sources = self.find(:all)
    array_of_ids = []
    action_sources.each do |action_source|
      array_of_ids << action_source.id
    end
    array_of_ids
  end

  def self.json_options
    { :only => [:name,
                :id]
    }
  end
end
