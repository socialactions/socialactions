class SameasApi
  unloadable

  def self.lookup uri, options = {}
    #require 'open-uri'
    require 'json'

    uri = "http://sameas.org/json?uri=#{CGI.escape(uri)}"
    p "SamesApi: looking up #{uri}"
    #file = open uri
    #json_text = file.read

    require 'api_cache'
    json_text = APICache.get(uri, API_CACHE_OPTIONS.merge({
      # Retain for a fairly long period, this data should be fairly static
      :cache => 604800 # 1 week
    }))

    begin
      data = JSON.parse(json_text)
    rescue
      return nil
    end
    return nil unless data
    return nil unless data.count >= 1

    result = {
      :duplicates => data.first['duplicates'] || []
    }

    result
  end

end
