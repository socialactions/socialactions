xml.instruct! :xml, :version => "1.0"
xml.actions do
  @actions.each do |action|
    xml.action do
      xml.title action.title
      xml.description sanitize(action.description)
      xml.url proxy_action_url(action)
      xml.latitude action.latitude
      xml.longitude action.longitude
      xml.image_url action.image_url
      xml.subtitle action.subtitle
      xml.goal_completed action.goal_completed
      xml.goal_amount action.goal_amount
      xml.goal_type action.goal_type
      xml.goal_number_of_contributors action.goal_number_of_contributors
      xml.initiator_name action.initiator_name
      xml.initiator_url action.initiator_url
      xml.initiator_email action.initiator_email
      xml.expires_at action.expires_at
      xml.platform_name action.platform_name
      xml.platform_url action.platform_url
      xml.platform_email action.platform_email
      xml.embed_widget action.embed_widget
      xml.organization_name action.organization_name
      xml.organization_url action.organization_url
      xml.organization_email action.organization_email
      xml.organization_ein action.organization_ein
      xml.tags action.tags
      xml.created_at action.created_at
      xml.score action.score
      xml.referrer_count action.referrer_count
      xml.action_type do
        xml.name action.action_type.name
        xml.id action.action_type.id
      end

      xml.site do
        xml.name action.site.name
        xml.url action.site.url
      end

      xml.entities do
        xml.rdf_uris do
          action.entities['rdf_uris'].each do |entity|
            xml.rdf_uri do
              xml.uri entity['name']
              xml.relevance entity['relevance']
              xml.confidence entity['confidence']
              xml.score entity['score']
            end
          end
        end

        xml.keywords do
          action.entities['keywords'].each do |entity|
            xml.rdf_uri do
              xml.name entity['name']
              xml.relevance entity['relevance']
              xml.confidence entity['confidence']
              xml.score entity['score']
            end
          end
        end
        
        xml.geolocations do
          action.entities['geolocations'].each do |entity|
            xml.geolocation do
              xml.name entity['name']
              xml.uri entity['uri']
              xml.map_uri entity['map_uri']
              xml.latitude entity['latitude']
              xml.longitude entity['longitude']
              xml.relevance entity['relevance']
              xml.confidence entity['confidence']
              xml.score entity['score']
            end
          end
        end
      end

    end
  end
end
