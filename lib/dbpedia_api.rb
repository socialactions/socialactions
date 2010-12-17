class DbpediaApi
  unloadable

  def self.uri_to_identifier uri
    pattern = /http:\/\/([^\.]+.)?dbpedia.org\/resource\/(.+)/
    return nil unless uri =~ pattern
    uri.gsub(pattern, '\2')
  end

  def self.identifier_to_uri identifier
    "http://dbpedia.org/resource/#{identifier}"
  end

  def self.lookup identifier, options = {}
    uri = "http://dbpedia.org/data/#{identifier}.json"

    #require 'open-uri'
    #file = open uri#, "Referer" => "#{APP_CONFIG[:site][:referrer]}"
    #json_text = file.read

    json_text = APICache.get(uri, :cache => 86400)

    begin
      # Note: ActiveSupport's json decoder appears to choke on unicode.
      data = JSON.parse json_text
    rescue StandardError => error
      # JSON decode error
      # if error == 'Invalid JSON string' ...
      return nil
    end
    return nil unless data

    name = 'n/a';
    description = 'n/a';
    thumbnail_uri = nil

    if (resource = data["http://dbpedia.org/resource/#{identifier}"])
      # Name not present for all resources in same key
#      resource["http://dbpedia.org/property/nameEnglish"].each do |element|
#        next unless element['lang'] == 'en'
#        name = element['value']
#        break
#      end if resource["http://dbpedia.org/property/nameEnglish"] || nil

      key = "http://dbpedia.org/property/name"
      resource[key].each do |element|
        next unless element['lang'] == 'en'
        name = element['value']
        break
      end if resource[key] || nil

      # TODO, did this change? Or are both possible?
      #key = "http://dbpedia.org/property/abstract"
      key = "http://dbpedia.org/ontology/abstract"
      resource[key].each do |element|
        next unless element['lang'] == 'en'
        description = element['value']
        break
      end if resource[key] || nil

      key = "http://dbpedia.org/ontology/thumbnail"
      resource[key].each do |element|
        next unless element['type'] == 'uri'
        thumbnail_uri = element['value']
        break
      end if resource[key] || nil
    end

    # Not using symbols for keys since this will be JSON-encoded and restored later
    result = {
      :entity_db => self.to_s,
      :identifier => identifier,
      :uri => identifier_to_uri(identifier),
      :name => name,
      :description => description,
      :thumbnail_uri => thumbnail_uri
    }
    result
  end

end
