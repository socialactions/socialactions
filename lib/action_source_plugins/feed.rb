require 'rfeedparser'
require 'feedparser_rssa_patch'

module Feed

  def parse
    feed.items.each do |entry|
      populate_action(entry) 
    end
    update_attribute(:needs_updating, false)
  end

  def feed
    @feed ||= FeedParser.parse(fetch(url).body)
  end
  
  def populate_action(entry)
    action = actions.find_or_create_by_url(entry.link)
    action.title = entry.title # TODO: handle text vs. html here
    action.url = entry.link
    action.description = description_for(entry)
    if entry.published_time or action.created_at.blank?
      action.created_at = entry.published_time || entry.updated_time || Time.now
    end
    action.updated_at = entry.updated_time if entry.updated_time
    figure_out_address_from(entry,action)
    action.organization_ein = entry.cb_ein # "legacy" support for 6deg pre-OA EIN

    unless entry.author_detail.blank?
      action.initiator_name = entry.author_detail.name
      action.initiator_email = entry.author_detail.email
      action.initiator_url = entry.author_detail.url
    end

    action.subtitle = entry.dcterms_alternative
    action.embed_widget = entry.oa_embedwidget

    if entry.oa_goal
      action.goal_completed = entry.oa_goal.oa_completed
      action.goal_amount = entry.oa_goal.oa_amount
      action.goal_type = entry.oa_goal.oa_type
      action.goal_number_of_contributors = entry.oa_goal.oa_numberofcontributors
    end
    
    if entry.dcterms_valid and entry.dcterms_valid.match(/(^|;)\s*end=([^;]+)/)
      action.expires_at = $2
    end
    
    unless entry.tags.blank?
      action_type_category = entry.tags.detect{ |t| 
        t.scheme == 'http://socialactions.com/action_types'
      }
      if action_type_category
        action.action_type = ActionType.find_by_name(action_type_category.term)
      end
      
      action.tags = entry.tags.reject{ |t| 
        t.scheme == 'http://socialactions.com/action_types'
      }.map{|t| Tag.find_or_create_by_name(t.term) }
    end
    
    if entry.oa_location
      action.location_city = entry.oa_location.oa_city
      action.location_country = entry.oa_location.oa_country
      action.location_state = entry.oa_location.oa_state
      action.location_postalcode = entry.oa_location.oa_postalcode
    end
      
    if entry.oa_platform
      action.platform_name = entry.oa_platform.oa_name
      action.platform_url = entry.oa_platform.oa_url
      action.platform_email = entry.oa_platform.oa_email
    end

    if entry.oa_organization
      action.organization_name = entry.oa_organization.oa_name
      action.organization_url = entry.oa_organization.oa_url
      action.organization_email = entry.oa_organization.oa_email
      action.organization_ein = entry.oa_organization.oa_ein
    end
    
    action.extract_entities

    action.save!
  end # populate_action
 
protected
  def figure_out_address_from(entry,action)
    if entry.geo_lat and entry.geo_long
      action.latitude = entry.geo_lat
      action.longitude = entry.geo_long
    end
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
  
end
