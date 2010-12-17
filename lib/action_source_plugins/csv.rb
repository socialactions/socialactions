require 'faster_csv'

# id
# description 
# url 
# title 
# created_at 
# updated_at
# latitude                    
# longitude                   
# location
# short_url
# image_url
# subtitle
# goal_completed
# goal_amount
# goal_type
# goal_number_of_contributors
# initiator_name
# initiator_url
# initiator_email
# expires_at
# dcterms_valid
# platform_name 
# platform_url 
# platform_email 
# embed_widget 
# organization_name 
# organization_url 
# organization_email 
# organization_ein 
# tags 
# redirect_id
# hit_count
# location_city
# location_country
# location_state
# location_postalcode
# disabled


module Csv

  def parse
    FasterCSV.foreach("#{RAILS_ROOT}/#{url}", :headers => true, :return_headers => false ) do |entry|
      populate_action(entry)
    end
  end

  def populate_action(entry)
    action = actions.find_or_create_by_url(entry.field('url').strip)

    # import text & number fields as-isfor each field listed here, we will import data from the CSV into the new record
    ['description', 'url', 'title', 'created_at', 'updated_at', 'latitude', 'longitude', 'location', 'short_url', 
      'image_url', 'subtitle', 'goal_completed', 'goal_amount', 'goal_type', 'goal_number_of_contributors', 
      'initiator_name', 'initiator_url', 'initiator_email', 'expires_at', 'dcterms_valid', 'platform_name', 
      'platform_url', 'platform_email', 'embed_widget', 'organization_name', 'organization_url', 
      'organization_email', 'organization_ein', 'tags', 'redirect_id', 'hit_count', 
      'location_city', 'location_country', 'location_state', 'location_postalcode', 'disabled'].each do |field|
      
      # if there's no data, don't bother setting this field
      next if entry.field(field).blank? or entry.field(field).strip.blank?
      
      value = entry.field(field).strip

      # make sure that date fields are set as date
      if ['created_at', 'updated_at', 'expires_at'].include?(field)
        value = value.to_date
      end
      if ['created_at', 'updated_at'].include?(field)
        # created and updated datestamps get a default value if not specified or not parsed correctly:
        value ||= Time.now # use now as the default if the csv entry couldn't be parsed to a date
      end
      
      RAILS_DEFAULT_LOGGER.debug("setting field '#{field}' to '#{value}' (#{value.class})")
      
      # otherwise, set the value for this field in our new record
      action.send((field+'=').to_sym, value)
    end
    
    # these fields are auto-set elsewhere
    # "action_source_id","int(11)","YES","","",""
    # "site_id","int(11)","YES","","",""
    # "action_type_id","int(11)","YES","","",""
    
    action.extract_entities
    
    action.save!
  end # populate_action

end
