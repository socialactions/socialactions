class Action < ActiveRecord::Base

  include GeoKit::Geocoders
  
  is_indexed :fields => ['title' , 'description', 'site_id', 'latitude', 'longitude', 'created_at', 'updated_at',
                        'action_type_id' ],
                        :delta => true

  belongs_to :feed
  belongs_to :site
  belongs_to :action_type
  
  acts_as_taggable
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  before_create :look_for_tags, :look_for_location, :geocode_lookup
  before_save :update_short_url, :denormalize

  
  def update_from_feed_entry(entry)
    puts "  -- Action: #{entry.title}"
    self.title = entry.title # TODO: handle text vs. html here
    self.url = entry.link
    self.description = description_for(entry)
    if entry.published_time or self.created_at.blank?
      self.created_at = entry.published_time || entry.updated_time || Time.now
    end
    self.updated_at = entry.updated_time if entry.updated_time
    figure_out_address_from(entry)

    self.initiator_name = entry.author_detail.name
    self.initiator_email = entry.author_detail.email
    self.initiator_url = entry.author_detail.url

    self.subtitle = entry.dcterms_alternative
    self.embed_widget = entry.rssa_embedwidget

    if entry.rssa_goal
      self.goal_completed = entry.rssa_goal.rssa_completed
      self.goal_amount = entry.rssa_goal.rssa_amount
      self.goal_type = entry.rssa_goal.rssa_type
      self.goal_number_of_contributors = entry.rssa_goal.rssa_numberofcontributors
    end
    
    self.dcterms_valid = entry.dcterms_valid
    if entry.dcterms_valid and entry.dcterms_valid.match(/(^|;)\s*end=([^;]+)/)
      self.expires_at = $2
    end
    
    action_type_name = entry.tags.detect{ |t| 
      t.scheme == 'tag:socialactions.com,2008:action_types'
    }.term
    self.action_type = ActionType.find_by_name(action_type_name)

    self.tags = entry.tags.reject{ |t| 
      t.scheme == 'tag:socialactions.com,2008:action_types'
    }.map{|t| t.term}

    if entry.rssa_platform
      self.platform_name = entry.rssa_platform.rssa_name
      self.platform_url = entry.rssa_platform.rssa_url
      self.platform_email = entry.rssa_platform.rssa_email
    end

    if entry.rssa_initiatororganization
      self.organization_name = entry.rssa_organization.rssa_name
      self.organization_url = entry.rssa_organization.rssa_url
      self.organization_email = entry.rssa_organization.rssa_email
      self.organization_ein = entry.rssa_organization.rssa_ein
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
    if self.short_url.nil? || Redirect.off?
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
                :created_at],
      :include => {:site => {:only => [:name, :url]}, 
                   :action_type => {:only => [:name, :id]}}
    }
  end
  
  def self.xml_options
    {:except => [:short_url]}
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
      Redirect.create(:cookie => 'social_actions', :url => self.read_attribute(:url))
      redirect = Redirect.get(:slug, :cookie => 'social_actions', :url => self.read_attribute(:url))
      self.short_url = redirect['url']
    rescue
      # It's ok, it's works just fine without the short url, we want to just continue
    end
  end
  
end
