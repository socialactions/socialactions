class Action < ActiveRecord::Base

  include GeoKit::Geocoders
  
  is_indexed :fields => ['title' , 'description', 'site_id', 'latitude', 'longitude', 'created_at', 'updated_at',
                        'action_type_id', 'hit_count' ],
                        :delta => true
                        
  attr_accessor :logs
  attr_accessor :referrer_count
  belongs_to :feed
  belongs_to :site
  belongs_to :action_type
  has_many :donations
  
  acts_as_taggable
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  before_create :look_for_tags, :look_for_location, :geocode_lookup
  before_save :update_short_url, :denormalize

  
  def logs
    @logs ||= Shorturl::Log.find_all_by_redirect_id(redirect_id)
  end
  
  def referrer_count
    Shorturl::Log.unique_referrers_for_logs(logs).size
  end
  
  def update_from_feed_entry(entry)
    self.title = entry.title # TODO: handle text vs. html here
    self.url = entry.link
    self.description = description_for(entry)
    if entry.published_time or self.created_at.blank?
      self.created_at = entry.published_time || entry.updated_time || Time.now
    end
    self.updated_at = entry.updated_time if entry.updated_time
    figure_out_address_from(entry)
    self.organization_ein = entry.cb_ein # "legacy" support for 6deg pre-OA EIN

    unless entry.author_detail.blank?
      self.initiator_name = entry.author_detail.name
      self.initiator_email = entry.author_detail.email
      self.initiator_url = entry.author_detail.url
    end

    self.subtitle = entry.dcterms_alternative
    self.embed_widget = entry.oa_embedwidget

    if entry.oa_goal
      self.goal_completed = entry.oa_goal.oa_completed
      self.goal_amount = entry.oa_goal.oa_amount
      self.goal_type = entry.oa_goal.oa_type
      self.goal_number_of_contributors = entry.oa_goal.oa_numberofcontributors
    end
    
    self.dcterms_valid = entry.dcterms_valid
    if entry.dcterms_valid and entry.dcterms_valid.match(/(^|;)\s*end=([^;]+)/)
      self.expires_at = $2
    end
    
    unless entry.tags.blank?
      action_type_category = entry.tags.detect{ |t| 
        t.scheme == 'http://socialactions.com/action_types'
      }
      if action_type_category
        self.action_type = ActionType.find_by_name(action_type_category.term)
      end
      
      self.tags = entry.tags.reject{ |t| 
        t.scheme == 'http://socialactions.com/action_types'
      }.map{|t| t.term}
    end
      
    if entry.oa_platform
      self.platform_name = entry.oa_platform.oa_name
      self.platform_url = entry.oa_platform.oa_url
      self.platform_email = entry.oa_platform.oa_email
    end

    if entry.oa_organization
      self.organization_name = entry.oa_organization.oa_name
      self.organization_url = entry.oa_organization.oa_url
      self.organization_email = entry.oa_organization.oa_email
      self.organization_ein = entry.oa_organization.oa_ein
    end

    #pp self.attributes
  end
  
  def description=(new_description)
    write_attribute(:description, fix_quoted_html(new_description))
  end
  
  def description_for(entry)
    # TODO: handle text vs. html here
    if entry.content && !entry.content[0].value.blank?
      entry.content[0].value
    elsif !entry.summary.blank?
      entry.summary
    else
      ""
    end
  end
  
  def url
    if self.short_url.nil? 
      read_attribute(:url)
    else
      self.short_url
    end
  end

  def self.per_page
    10
  end

  def self.json_options
    { :only => [:title, 
                :description, 
                :url,  
                :location, 
                :created_at,
                :hit_count],
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
    if feed.location_finder and self.description
      match = self.description.match(feed.location_finder.to_s)
      self.location = match[1] if match and match[1]
      puts "     Found Location: #{self.location}"
    end
  end
  
  def look_for_tags
    if feed.tag_finder and description
      match = description.match(feed.tag_finder.to_s)
      self.tag_list = match[1] if match and match[1]
      puts "     Found Tags: #{self.tag_list}"
    end
  end

  def figure_out_address_from(entry)
    if entry.geo_lat and entry.geo_long
      self.latitude = entry.geo_lat
      self.longitude = entry.geo_long
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
    self.site_id = self.feed.site_id
    self.action_type ||= self.feed.action_type
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
