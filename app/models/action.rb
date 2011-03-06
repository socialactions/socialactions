class Action < ActiveRecord::Base

  include GeoKit::Geocoders
  include ExpireActions
  include ActionView::Helpers::SanitizeHelper
  include LoggedDeletion

  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  
  # https://github.com/outoftime/sunspot/wiki/setting-up-classes-for-search-and-indexing
  searchable do
    # The all_text field concatenates several important fields to be used in
    # calculating a boost per query specified term boosts.
    text :all_text, :stored => true
    string :title
    text :title, :stored => true, :default_boost => 2
    text :description, :stored => true
    text :stripped_description, :stored => true
    text :subtitle
    text :tags
    text :embed_widget
    integer :site_id
    integer :hit_count
    integer :goal_number_of_contributors
    integer :action_source_id
    integer :action_type_id
    boolean :disabled
    time :created_at
    time :updated_at
    time :expires_at
    float :latitude
    float :longitude
    float :goal_completed
    float :goal_amount
    string :location
    string :goal_type
    string :initiator_name
    string :initiator_email
    string :initiator_url
    string :platform_name
    string :platform_url
    string :platform_email
    string :organization_name
    string :organization_email
    string :ein, :using => :organization_ein
  end

  attr_accessor :logs
  attr_accessor :referrer_count
  attr_accessor :score
  belongs_to :action_source
  belongs_to :site
  belongs_to :action_type
  has_many :donations
  serialize :entities
  serialize :nlp_result
  
  acts_as_taggable
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  validates_each :action_source do |record, attr, value|
    record.errors.add attr, 'is disabled so you can not enable this action' if value.disabled == false && record.action_source.disabled == true
  end


  before_create :look_for_tags, :look_for_location, :geocode_lookup
  before_save :update_short_url, :denormalize

  before_validation :set_defaults
  def set_defaults
    self.created_at ||= Time.now
    set_expiration
  end

	named_scope :expired,
		:conditions => "(disabled = 0 OR disabled IS NULL) AND NOW() > expires_at"

	named_scope :long_disabled,
		:conditions => "disabled = 1 AND TIMESTAMPDIFF(DAY, disabled_on, NOW()) > 30"

  def set_expiration
    return if self.action_source.action_lifespan.nil?
    self.expires_at ||= self.created_at + self.action_source.action_lifespan.to_i.days
  end

  def logs
    @logs ||= Shorturl::Log.find_all_by_redirect_id(redirect_id)
  end
  
  def referrer_count
    Shorturl::Log.unique_referrers_for_logs(logs).size
  end
  
  def description=(new_description)
    write_attribute(:description, fix_quoted_html(new_description || ''))
  end

  def stripped_description
    strip_tags(description || '')
  end
  
  def disabled=(bit)
    bit = (bit.to_i != 0) if bit.is_a? String
    if bit && self.disabled.nil?
      self.disabled_on = DateTime.now.to_date
    elsif !bit
      self.disabled_on = nil
    end
    write_attribute(:disabled, bit)
  end

  def self.per_page
    10
  end

  def self.json_options
    { :only => [:id,
                :title,
                :description, 
                :url,
                :location, 
                :latitude,
                :longitude,
                :image_url,
                :subtitle,
                :goal_completed,
                :goal_amount,
                :goal_type,
                :goal_number_of_contributors,
                :initiator_name,
                :initiator_url,
                :initiator_email,
                :expires_at,
                :platform_name,
                :platform_url,
                :platform_email,
                :embed_widget,
                :organization_name,
                :organization_url,
                :organization_email,
                :organization_ein,
                :tags,
                :created_at,
                :hit_count,
                :result_count,
                :page_count],
      :methods =>[:score, :entities, :referrer_count],
      :include => {:site => {:only => [:name, :url]}, 
                   :action_type => {:only => [:name, :id]}}
    }
  end
  
  def self.xml_options
    {:except => [:short_url]}
  end
  
  def update_hit_count
    unless self.redirect_id.nil?
      self.hit_count = Shorturl::Redirect.find_by_id(self.redirect_id).logs.size
    end
  end

  def self.nlp_fields
    [:title, :subtitle, :description]
  end

  def nlp_fields_values
    action = self
    self.class.nlp_fields.map{|f| action.send(f.to_s)}
  end

  def nlp_fields_changed?
    action = self
    self.class.nlp_fields.inject(false) {|a, f| a || action.send(f.to_s + '_changed?')}
  end

  def maybe_reextract_entities
    return unless self.nlp_fields_changed?
    self.nlp_result = nil
    self.entities = nil
    extract_entities
  end

  def query_nlp
    p "Action##{self.id} query_nlp"
    @@app_config ||= YAML::load(File.open("#{RAILS_ROOT}/config/application.yml"))
    @@zemanta ||= ZemantaApi.new :api_key => @@app_config['zemanta']['api_key']
    self.nlp_result = @@zemanta.query nlp_fields_values.reject{|s| s.blank?}
  end

  def extract_entities
    self.entities = nil

    begin
      query_nlp if self.nlp_result.blank?
      raise "Unsuccessful status reported" unless (nlp_result['status'] == 'ok' rescue false)

    rescue => exc
      p "*** Exception Action#extract_entities: #{exc.to_s}"
      self.entities = nil
      return
    end

    # Note: storing to virtual (non-db) attribute
    self.entities = ZemantaApi.extract_entities nlp_result
  end

  def delete_entity args
    entities = self.entities
    name = CGI.unescape args['name']
    begin
      entities[args['type']].reject!{|e| e['name'] == name}
      self.entities = entities
    rescue
    end
  end

  def create_entity args
    if (r = args['relevance'].to_i) > 1 || r < 0
      errors.add_to_base "Relevance must be between 0 and 1"
      return false
    end

    entities = self.entities
    begin
      entity = {}
      entities[args['type']].push entity
    rescue
      errors.add_to_base "Entity creation failed, please try again."
      return false
    end

    entity['name'] = args['name']
    entity['relevance'] = args['relevance'].to_f
    self.entities = entities
    save
  end

  def update_entity args
    if (r = args['relevance'].to_i) > 1 || r < 0
      errors.add_to_base "Relevance must be between 0 and 1"
      return false
    end

    entities = self.entities
    begin
      orig_name = CGI.unescape args['orig_name']
      entity = entities[args['type']].select{|e| e['name'] == orig_name}.first
    rescue
      errors.add_to_base "Entity not found, please try again."
      return false
    end

    entity['name'] = args['name']
    entity['relevance'] = args['relevance'].to_f
    self.entities = entities
    save
  end

  def update_entities
    extract_entities
    save!
  end

  named_scope :without_nlp, {
    :conditions => "nlp_result IS NULL OR nlp_result = ''"
  }

  named_scope :with_nlp, {
    :conditions => "nlp_result IS NOT NULL AND nlp_result != ''"
  }

  named_scope :without_entities, {
    :conditions => "entities IS NULL OR entities = ''"
  }

  def self.update_actions_without_entities
    self.without_entities.all.each {|a| a.update_entities}
  end

  def entities
    self[:entities] || {}
  end

  def entities_count
    self.entities.values.inject{|count, entities| entities.count} || 0
  end

  def find_or_create_redirect
    require 'shorturl/redirect'
    redirect = Shorturl::Redirect.find_or_create_by_cookie_and_url(:cookie => 'social_actions', :url => self[:url])
    redirect.save!
    redirect
  end

  def update_short_url
    if self[:url].blank?
      warn "short_url for Action##{self.id} didn't work, url is blank"
      return
    end

    begin
      redirect = find_or_create_redirect
      self.redirect_id = redirect.id
      self.short_url = redirect.slug
    rescue Exception => message
      warn "short_url for Action##{self.id} didn't work #{message}"
      # It's ok, it works just fine without the short url, we want to just log it and continue
    end
  end

  # Use the short_url if present
  # Note:
  #   REDIRECT_PREFIX is defined in config/environments/{env}.rb
  #   Idea is to have a different (sub)domain for these short URI's
  def proxy_action_url
    self.short_url.present? ? REDIRECT_PREFIX + self.short_url : self[:url]
  end

  def url
    if self.disabled
      ""
    else
      self.proxy_action_url
    end
  end

protected
  def fix_quoted_html(text)
    text.gsub(/\&lt;/, '<').gsub(/\&gt;/, '>')
  end

  def look_for_location
    if action_source.respond_to? 'location_finder'   
      if action_source.location_finder and self.description
        match = self.description.match(action_source.location_finder.to_s)
        self.location = match[1] if match and match[1]
        puts "     Found Location: #{self.location}"
      end
    end
  end
  
  def look_for_tags
    if action_source.respond_to? 'tag_finder'
      if action_source.tag_finder and self.description
        match = description.match(action_source.tag_finder.to_s)
        self.tag_list = match[1] if match and match[1]
        puts "     Found Tags: #{self.tag_list}"
      end
    end
  end
  
  def geocode_lookup
    unless location.nil? or location.empty?
      result = MultiGeocoder.geocode(location)
      if result.success
        self.latitude = result.lat
        self.longitude = result.lng
        puts "     Geocoding Successful - #{result}" 
      end
    end
  end
  
  
  def denormalize
    self.site_id = self.action_source.site_id
    self.platform_name = self.action_source.name
    self.platform_url = self.action_source.url
    self.action_type ||= self.action_source.action_type
  end
  
  # Convert a float point value from 0 to 1 into an integral number of repetitions
  # for generating search text.
  # Result: 1..6 (6 should be very rare)
  def self.relevance_multiplier relevance
    (relevance.to_f * 5 + 1).to_i
  end

  def all_text
    delim = "\r\n"
    str = ""

    unless title.blank?
      str << title + delim * 2
    end

    unless subtitle.blank?
      str << subtitle + delim * 2
    end

    unless description.blank?
      str << description + delim * 2
    end

    (self.entities['keywords'] || [] rescue []).each do |keyword|
      str << keyword['name'] + delim * 2
    end

    (self.entities['rdf_uris'] || [] rescue []).each do |rdf_uri|
      str << rdf_uri['name'].block_uri_tokenization + delim * 2
    end

    str
  end

end
