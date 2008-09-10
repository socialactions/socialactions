xml.instruct!
xml.feed :xmlns => 'http://www.w3.org/2005/Atom' do 
  xml.title "Social Actions: Results for #{@search.to_s}"
  xml.id "tag:socialactions.com,2008:search:#{request.request_uri}"
  xml.link :rel => 'self', :href => feed_url
  xml.author{ xml.name  'Social Actions' }

  xml.updated @actions.first.updated_at.xmlschema unless @actions.empty?

  @actions.each do |action|
    xml.entry do
      xml.id "tag:socialactions.com,#{action.created_at.strftime('%Y-%m-%d')}:Action:#{action.id}"
      xml.published action.created_at.xmlschema if action.created_at
      xml.updated action.updated_at.xmlschema if action.updated_at

      xml.title action.title
      xml.content sanitize(action.description), :type => 'html'
      xml.link :href => action.url # action_url(action)
      xml.category :term => action.action_type.name
    end
  end
end
