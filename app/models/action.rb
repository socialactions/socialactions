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

  
  def update_from_feed_item(item)
    puts "  -- Action: #{item.title}"
    self.title = item.title
    self.url = item.link
    self.description = description_for(item)
    self.created_at = item.pubDate if item.pubDate
    self.created_at = item.dc_date if item.dc_date
    self.created_at = item.updated if item.updated
    figure_out_address_from(item)
  end
  
  def description=(new_description)
    write_attribute(:description, fix_quoted_html(new_description))
  end
  
  # Seems like Atom uses <content> not <description> ?? 
  def description_for(item)
    if item.description
      item.description
    elsif item.content
      item.content
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

  def figure_out_address_from(item)
    if item.geo_lat and item.geo_long
      self.latitude = item.geo_lat
      self.longitude = item.geo_long
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
    self.action_type = self.feed.action_type
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
