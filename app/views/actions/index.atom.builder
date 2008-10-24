xml.instruct!
xml.feed(:xmlns => 'http://www.w3.org/2005/Atom', 
         'xmlns:rssa' => 'http://socialactions.com/rssa/beta',
         'xmlns:dcterms' => 'http://purl.org/dc/terms/') do 
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
      xml.dcterms :alternative, action.subtitle unless action.subtitle.blank?
      unless action.initiator_name.blank?
        xml.author do
          xml.name action.initiator_name
          xml.url action.initiator_url unless action.initiator_url.blank?
        end
      end
      xml.content sanitize(action.description), :type => 'html'
      xml.link :href => action.url # action_url(action)
      unless action.goal_amount.blank? and action.goal_type.blank? and action.goal_completed.blank? and action.goal_number_of_contributors.blank?
        xml.rssa :goal do
          xml.rssa :amount, action.goal_amount unless action.goal_amount.blank?
          xml.rssa :type, action.goal_type unless action.goal_type.blank?
          xml.rssa :completed, action.goal_completed unless action.goal_completed.blank?
          xml.rssa :numberOfContributors, action.goal_number_of_contributors unless action.goal_number_of_contributors.blank?
        end
      end
      xml.dcterms :valid, action.dcterms_valid unless action.dcterms_valid.blank?
      xml.category :term => action.action_type.name, :scheme => 'http://socialactions.com/action_types'
      action.tags.each do |tag|
        xml.category :term => tag
      end
      unless action.platform_name.blank? and action.platform_url.blank? and action.platform_email.blank?
        xml.rssa :platform do
          xml.rssa :name, action.platform_name unless action.platform_name.blank?
          xml.rssa :url, action.platform_url unless action.platform_url.blank?
          xml.rssa :email, action.platform_email unless action.platform_email.blank?
        end
      end
      xml.rssa :embedWidget, action.embed_widget unless action.embed_widget.blank?
      unless action.organization_name.blank? and
          action.organization_url.blank? and
          action.organization_ein.blank? and
          action.organization_email.blank?
        xml.rssa :organization do
          xml.rssa :name, action.organization_name unless action.organization_name.blank?
          xml.rssa :url, action.organization_url unless action.organization_url.blank?
          xml.rssa :ein, action.organization_ein unless action.organization_ein.blank?
          xml.rssa :email, action.organization_email unless action.organization_email.blank?
        end
      end

    end
  end
end
