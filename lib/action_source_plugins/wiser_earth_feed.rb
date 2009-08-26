require 'xml'
require 'digest/md5'
require 'open-uri'

module WiserEarthFeed
  
  MAIN_URL = "http://www.wiserearth.org"
  
  def parse
    case api_data_type
    when "events"
      parse_items doc_for_xml(feed), 'event'
    when "jobs"
      parse_items doc_for_xml(feed), 'job'
    when "groups"
      parse_items doc_for_xml(feed), 'group'
    end
    #update_attribute(:needs_updating, false)
  end
  
  def doc_for_xml(xml)
    parser, parser.string = XML::Parser.new, xml
    doc, statuses = parser.parse, []
    doc
  end
  
  def parse_items(doc,node)
    doc.find("//rsp/results/#{node}").each do |entry|
      node = entry
      if api_data_type != 'groups'
        entry_doc = doc_for_xml feed_entry(entry.attributes.to_h['id'])  
        node = entry_doc.find("//rsp//#{node}").first
      end
      populate_action(node)
    end
  end

  def feed
    open("#{self.url}&sig=#{api_signature}&key=#{api_key}").read # http://www.wiserearth.org/events/api_search?r=1&language=EN&sig=<signature>&key=<apiKey>
  end
  
  def feed_entry(masterid)
     open("#{MAIN_URL}/#{api_data_type}/#{masterid}?sig=#{api_signature_for_id(masterid)}&key=#{api_key}").read
  end
  
  def api_key
    json_additional_data['key'] || raise("WiserEarth requires an api key!")
  end
  
  def api_secret
    json_additional_data['secret'] || raise("WiserEarth requires a secret to access data!")
  end
  
  def api_data_type
    json_additional_data['data_type'] || raise("WiserEarth requires a data type!")
  end
  
  def api_signature_for_id(id)
    Digest::MD5.hexdigest("masterid#{id}#{api_secret}")
  end
  
  def api_signature
    Digest::MD5.hexdigest("#{param_key_for_url(self.url)}#{api_secret}")
  end
  
  def param_key_for_url(url)
    sigStr = url.split("?").last
    sigStr.gsub!(/&/,'')
    sigStr.gsub!(/=/,'')
  end
  
  def populate_action(entry)
    attributes = entry.attributes.to_h
    action = actions.find_or_create_by_url(attributes['href'])
    action.title = attributes['Event'] || attributes['Position'] || attributes['Name']# TODO: handle text vs. html here
    action.url = attributes['href']
    if api_data_type == 'groups'
      action.description = entry.find('About').first.content
    else
      action.description = entry.find('SpecialTextList/About').first.content
    end
    #if entry.published_time or action.created_at.blank?
    action.created_at = attributes['Created'] if attributes['Created']
    #end
    action.updated_at = attributes['Updated'] if attributes['Updated']
    #figure_out_address_from(entry,action)
    #action.organization_ein = entry.cb_ein # "legacy" support for 6deg pre-OA EIN

    #unless entry.author_detail.blank?
      action.initiator_name = attributes['Contact_name']
      action.initiator_email = attributes['Contact_email']
      #action.initiator_url = entry.author_detail.url
    #end

    #action.subtitle = entry.dcterms_alternative
    #action.embed_widget = entry.oa_embedwidget

    #if entry.oa_goal
      #action.goal_completed = entry.oa_goal.oa_completed
      #action.goal_amount = entry.oa_goal.oa_amount
      #action.goal_type = entry.oa_goal.oa_type
      #action.goal_number_of_contributors = entry.oa_goal.oa_numberofcontributors
    #end
    
    #action.dcterms_valid = entry.dcterms_valid
    #if entry.dcterms_valid and entry.dcterms_valid.match(/(^|;)\s*end=([^;]+)/)
      #action.expires_at = $2
    #end
    
    #unless entry.tags.blank?
    #  action_type_category = entry.tags.detect{ |t| 
    #    t.scheme == 'http://socialactions.com/action_types'
    #  }
    #  if action_type_category
    #    action.action_type = ActionType.find_by_name(action_type_category.term)
    #  end
      
    #  action.tags = entry.tags.reject{ |t| 
    #    t.scheme == 'http://socialactions.com/action_types'
    #  }.map{|t| t.term}
    #end
    
    #if entry.oa_location
      action.location_city = attributes['City']
      action.location_country = attributes['Country']
      action.location_state = attributes['State']
      action.location_postalcode = attributes['Postal_code'] || attributes['Postal_Code']
    #end
      
    #if entry.oa_platform
    #  action.platform_name = entry.oa_platform.oa_name
    #  action.platform_url = entry.oa_platform.oa_url
    #  action.platform_email = entry.oa_platform.oa_email
    #end

    #if entry.oa_organization
    #  action.organization_name = entry.oa_organization.oa_name
    #  action.organization_url = entry.oa_organization.oa_url
    #  action.organization_email = entry.oa_organization.oa_email
    #  action.organization_ein = entry.oa_organization.oa_ein
    #end
    
    action.save!
  end # populate_action

end