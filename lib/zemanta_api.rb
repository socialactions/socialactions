class ZemantaApi
  unloadable
  
  @@api_uri = "http://api.zemanta.com/services/rest/0.0/"

  def initialize config, args = {}
    @@config = config
    # http://developer.zemanta.com/docs/suggest/

    @@default_query_params = {
      :format => "json",
      :method => "zemanta.suggest",
      :return_rdf_links => 1,
      :return_images => 0,
      :return_articles => 0,
      :articles_limit => 0,
      #:articles_highlight => 1,
      :return_keywords => 1,
      :return_rich_objects => 0,
      :api_key => @@config[:api_key]
    }

    @@default_query_params.merge! args[:default_query_params] if args.include? :default_query_params

    self
  end

  def set_config config
  end

  # Translate URI as necessary
  def self.extract_uri uri
    if matches = uri.match(/^http:\/\/r\.zemanta\.com\/\?u=([^&]+)/)
      return CGI.unescape matches[1]
    end
    uri
  end

  def query text, args = {}
    begin
      params = @@default_query_params
      params.merge! args[:params] if args.include? :params
      
      if text.is_a?(Array)
        params[:text] = ''
        text.each do |str|
          # Break up sections with two newlines to separate logically to API
          params[:text] << str
          params[:text] << "\r\n\r\n"
        end
      elsif text.is_a?(String)
        params[:text] = text
      else
        raise "Invalid text parameter"
      end

     
      require 'api_cache'
      require 'digest/md5'
      cache_key = Digest::MD5.hexdigest(@@api_uri + params.inspect)

      body = APICache.get(cache_key, API_CACHE_OPTIONS.merge({})) do
        response = Net::HTTP.post_form URI.parse(@@api_uri), params
      
        if @@config[:verbose] || nil
          logger.info 'Zemanta::query ' + params.inspect
          logger.info 'Zemanta::query response code ' + response.code
          logger.info 'Zemanta::query response body ' + response.body
        end
        

        unless response.code == '200'
          raise "Unsuccessful request, response code #{response.code}"
        end
        

        if response.body.blank?
          raise "No response body received"
        end
        
        response.body
      end

      require 'json'
      JSON.parse body

    rescue => error
      p "ERROR", error.inspect
      raise
    end
  end

  def self.extract_entities body
    # Parse disambiguated entities
    entities = {
      'rdf_uris' => {},
      'keywords' => {},
      'geolocations' => {}
    }
    (body['markup']['links'] rescue []).each do |link|
      resource = nil
      (link['target'] || []).each do |target|
        # Add entity as keyword
        entities['keywords'][target['title'].downcase] ||= {
          'name' => target['title'],
          'relevance' => link['relevance'],
          'score' => link['relevance']
        }

        case target['type']
        when 'rdf':
          entities['rdf_uris'][target['url']] = {
            'name' => target['url'],
            'relevance' => link['relevance'].to_f,
            'confidence' => link['confidence'].to_f,
            'score' => link['confidence'].to_f * link['relevance']
          }
          if link['entity_type'].to_s == '/location/location' && target['url'].match(/^http:\/\/rdf\.freebase\.com\//)
            # Query freebase for latitude and longitude"
            require 'freebase_api'
            geolocation = FreebaseApi.query_geolocation target['url']
            unless geolocation.blank?
              entities['geolocations'][target['title']] = {
                'name' => target['title'],
                'uri' => target['url'],
                'latitude' => geolocation['latitude'],
                'longitude' => geolocation['longitude'],
                'relevance' => link['relevance'].to_f,
                'confidence' => link['confidence'].to_f,
                'score' => link['confidence'].to_f * link['relevance'],
                'map_uri' => "http://maps.google.com/maps?ll=#{geolocation['latitude']},#{geolocation['longitude']}&q=#{geolocation['latitude']},#{geolocation['longitude']} (#{target['title']})&t=h&span=1.0,1.0&z=8"
              }
            end
          end
        end

      end
    end

    # Parse keywords
    (body['keywords'] || []).each do |keyword|
      entities['keywords'][keyword['name'].downcase] ||= {
        'name' => keyword['name'],
        'confidence' => keyword['confidence'].to_f,
        'score' => keyword['confidence'].to_f
      }
    end

    ['rdf_uris', 'keywords', 'geolocations'].each do |type|
      entities[type] = entities[type].values.sort{|a, b| b['score'] <=> a['score']}
    end

    entities
  end

end
