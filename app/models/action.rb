class Action < ActiveRecord::Base

  include GeoKit::Geocoders
  
  is_indexed :fields => ['title' , 'description', 'site_id', 'latitude', 'longitude', 'created_at', 'updated_at',
                        'action_type_id', 'hit_count', 'location', 'subtitle', 'goal_completed', 'goal_amount', 
                        'goal_type', 'goal_number_of_contributors', 'initiator_name', 'initiator_url', 'initiator_email', 'expires_at',
                        'dcterms_valid', 'platform_name', 'platform_url', 'platform_email', 'embed_widget', 
                        'organization_name', 'organization_email', 'tags', 'disabled', {:field => 'organization_ein', :as => 'ein', :sortable => true}],
             :delta => true
                        
  attr_accessor :logs
  attr_accessor :referrer_count
  belongs_to :action_source
  belongs_to :site
  belongs_to :action_type
  has_many :donations
  
  acts_as_taggable
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  validates_each :action_source do |record, attr, value|
    record.errors.add attr, 'is disabled so you can not enable this action' if value.disabled == false && record.action_source.disabled == true
  end


  before_create :look_for_tags, :look_for_location, :geocode_lookup
  before_save :update_short_url, :denormalize

  
  def logs
    @logs ||= Shorturl::Log.find_all_by_redirect_id(redirect_id)
  end
  
  def referrer_count
    Shorturl::Log.unique_referrers_for_logs(logs).size
  end
  
  def description=(new_description)
    write_attribute(:description, fix_quoted_html(new_description))
  end
  
  def url
    if self.disabled
      ""
    elsif self.short_url.nil? 
      read_attribute(:url)
    else
      self.short_url
    end
  end
  
  def disabled=(bit)
    if bit && self.disabled.nil?
      self.disabled_on = DateTime.now
    elsif !bit
      self.disabled_on = nil
    end
    write_attribute(:disabled, bit)
  end
  

  def self.per_page
    10
  end

  def self.json_options
    { :only => [:title, 
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
                :dcterms_valid,
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
      :methods =>[:referrer_count],
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
  
  def update_short_url
    begin
      redirect = Shorturl::Redirect.find_or_create_by_cookie_and_url(:cookie => 'social_actions', :url => self.read_attribute(:url))
      redirect.save!
      
      self.redirect_id = redirect.id
      self.short_url = "http://#{Shorturl::Redirect.domain}/#{redirect.slug}"
    rescue Exception => message
      warn "short_url didn't work #{message}"
      # It's ok, it works just fine without the short url, we want to just log it and continue
    end
  end
  
end
