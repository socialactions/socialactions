require 'uri'
require 'net/http'
require 'base64'
require 'digest'
require 'json'
require 'parsedate'


module VolunteerMatch
  
  def parse
    opportunities = JSON.parse(feed)["opportunities"]
    
    opportunities.each do |opportunity|
      populate_action(opportunity)
    end

  end
  

  def feed
    uri = URI(self.url)
    http = Net::HTTP.new(uri.host, uri.port)

    nonce = Base64.encode64((0...20).map{65.+(rand(25)).chr}.join).strip
    now = Time.now.strftime("%Y-%m-%dT%H:%M:%S+0000")
    password = Base64.encode64(Digest::SHA256.digest(nonce + now + api_key)).strip
    headers = {
        'Accept-Charset' => "UTF-8",
        'Content-Type' => 'application/json',
        'Authorization' => 'WSSE profile="UsernameToken"',
        'X-WSSE' => 'UsernameToken Username="' + api_username + '", PasswordDigest="' + password + '", Nonce="' + nonce +' ", Created="' + now + '"'
    }
    path = URI.escape('/api/call?action=searchOpportunities&query={"virtual": true, "sortCriteria": "update", "numberOfResults": 10, "fieldsToDisplay": ["title", "description", "vmUrl", "updated", "created", "parentOrg"]}')

    result = ""
    http.get(path, headers) do |chunk|
        result << chunk
    end
    
    result
  end


  def api_username
    json_additional_data['username'] || raise("Volunteer Match requires a username!")
  end


  def api_key
    json_additional_data['key'] || raise("Volunteer Match requires an api key!")
  end

  
  def populate_action(entry)
    begin
      url = URI.unescape(entry["vmUrl"])
      
      action = actions.find_or_create_by_url(url)
      action.url = url

      action.title = entry["title"]
      action.description = entry["description"]
      action.created_at = Time.mktime(*ParseDate.parsedate(entry["created"]))

      if !entry["parentOrg"].nil?
        action.organization_name = entry["parentOrg"]["name"]
      end

      action.extract_entities
      
      action.save!
    rescue
    end

  end # populate_action

end
