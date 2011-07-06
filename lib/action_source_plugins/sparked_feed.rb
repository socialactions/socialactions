require 'libxml'
require 'digest/md5'
require 'open-uri'

module SparkedFeed
  
  def parse
    parse_items doc_for_xml(feed)
    #update_attribute(:needs_updating, false)
  end
  
  def doc_for_xml(xml)
    parser, parser.string = LibXML::XML::Parser.new, xml
    doc, statuses = parser.parse, []
    doc
  end
  
  def parse_items(doc)
    doc.find("//challenges/challenge").each do |entry|
      populate_action(entry)
    end
  end

  def feed
    open(self.url).read 
  end
  
  def populate_action(entry)
    url = entry.find("url").first.content
    
    action = actions.find_or_create_by_url(url)
    action.url = url

    action.title = entry.find("title").first.content
    action.description = entry.find("description").first.content
    action.expires_at = Date.parse(entry.find("deadline").first.content)


    action.initiator_name = "#{entry.find("seeker/firstName").first.content} #{entry.find("seeker/lastName").first.content}"
    action.initiator_url = entry.find("seeker/sparkedProfileUrl").first.content unless entry.find("seeker/sparkedProfileUrl").first.nil?

    action.organization_name = entry.find("seeker/orgName").first.content unless entry.find("seeker/orgName").first.nil?
    action.organization_url = entry.find("seeker/orgUrl").first.content unless entry.find("seeker/orgUrl").first.nil?

    action.location = entry.find("seeker/location").first.content unless entry.find("seeker/location").first.nil?
    
    action.extract_entities
    
    action.save!

  end # populate_action

end
