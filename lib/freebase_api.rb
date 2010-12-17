class FreebaseApi
  unloadable

  def self.uri_to_identifier uri
    pattern = /http:\/\/([^\.]+.)?freebase.com(\/ns)?(.+)/
    return nil unless uri =~ pattern
    uri.gsub(pattern, '\3')
  end

  def self.identifier_to_uri identifier
    "http://www.freebase.com#{identifier}"
  end

  def self.lookup identifier, options = {}
    mode = options[:xrefs] ? 'standard' : 'basic'
    uri = "http://www.freebase.com/experimental/topic/#{mode}?id=#{identifier}"

    #require 'open-uri'
    #file = open uri
    #json_text = file.read

    json_text = APICache.get(uri, API_CACHE_OPTIONS)

    data = JSON.parse(json_text)
    return nil unless data
    entity_data = data[identifier]
    return nil unless entity_data && entity_data[:status.to_s] == '200 OK'
    return nil unless entity_data[:code.to_s] == '/api/status/ok'
    return nil unless entity_result = entity_data[:result.to_s]

    result = {
      :entity_db => self.to_s,
      :identifier => identifier,
      :uri => identifier_to_uri(identifier),
      :name => entity_result[:text.to_s],
      :description => entity_result[:description.to_s],
      :thumbnail_uri => entity_result[:thumbnail.to_s],
      :xrefs => []
    }

    result
  end

  def self.query_geolocation uri
    query = ({
      :query => {
        :id => self.uri_to_identifier(uri),
        :type => '/location/location',
        :geolocation => {
          :latitude => nil,
          :longitude => nil,
        }
      }
    }).to_json
    uri = "http://www.freebase.com/api/service/mqlread?query=#{CGI.escape(query)}"

    json_text = APICache.get(uri, API_CACHE_OPTIONS)
    data = JSON.parse(json_text)

    return nil unless (data['status'] rescue nil) == '200 OK'
    return (data['result']['geolocation'] rescue nil)
  end

end
