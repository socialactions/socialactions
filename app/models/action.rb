class Action < ActiveRecord::Base

  include GeoKit::Geocoders
  
  is_indexed :fields => ['title' , 'description', 'site_id', 'latitude', 'longitude', 'created_at', 'updated_at',
                        'action_type_id' ],
                        :delta => true

  belongs_to :feed
  belongs_to :site
  belongs_to :action_type
  has_many :donations
  
  acts_as_taggable
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  before_save :look_for_tags, :look_for_location, :geocode_lookup, :denormalize
  
  def update_from_feed_entry(entry)
    puts "  -- Action: #{entry.title}"
    self.title = entry.title # TODO: handle text vs. html here
    self.url = entry.link
    self.description = description_for(entry)
    self.created_at = entry.updated_time || Time.now
    figure_out_address_from(entry)
    self.ein = entry.cb_ein # "legacy" support for 6deg pre-RSSA EIN
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
    self.action_type = self.feed.action_type
  end
  
end
