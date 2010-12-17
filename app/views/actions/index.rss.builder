xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:oa' => 'http://socialactions.com/oa/beta', 'xmlns:dcterms' => 'http://purl.org/dc/terms/' do
  xml.channel do
    xml.title "Social Actions: Results for #{@search.to_s}"
    xml.description "Results for #{@search.to_s} on http://mashup.socialactions.com"
    xml.link feed_url
    xml.oa :result_count, @actions.total_entries
    xml.oa :page_count, @actions.total_entries / @search.limit
  
    @actions.each do |action|
      xml.item do
        xml.title       action.title
        xml.category    action.action_type.name
        xml.description sanitize(action.description)
        xml.pubDate     action.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
        xml.link        proxy_action_url(action)
        xml.guid        proxy_action_url(action)
        xml.dcterms :alternative, action.subtitle unless action.subtitle.blank?
        unless action.initiator_name.blank?
          xml.atom :author do
            xml.atom :name, action.initiator_name
            xml.atom :url, action.initiator_url unless action.initiator_url.blank?
          end
        end
        unless action.goal_amount.blank? and action.goal_type.blank? and action.goal_completed.blank? and action.goal_number_of_contributors.blank?
          xml.oa :goal do
            xml.oa :amount, action.goal_amount unless action.goal_amount.blank?
            xml.oa :type, action.goal_type unless action.goal_type.blank?
            xml.oa :completed, action.goal_completed unless action.goal_completed.blank?
            xml.oa :numberOfContributors, action.goal_number_of_contributors unless action.goal_number_of_contributors.blank?
          end
        end
        xml.dcterms :valid, action.dcterms_valid unless action.dcterms_valid.blank?
        xml.atom :category, :term => action.action_type.name, :scheme => 'http://socialactions.com/action_types'
        action.tags.each do |tag|
          xml.atom :category, :term => tag
        end
        unless action.platform_name.blank? and action.platform_url.blank? and action.platform_email.blank?
          xml.oa :platform do
            xml.oa :name, action.platform_name unless action.platform_name.blank?
            xml.oa :url, action.platform_url unless action.platform_url.blank?
            xml.oa :email, action.platform_email unless action.platform_email.blank?
          end
        end
        xml.oa :embedWidget, action.embed_widget unless action.embed_widget.blank?
        unless action.organization_name.blank? and
            action.organization_url.blank? and
            action.organization_ein.blank? and
            action.organization_email.blank?
          xml.oa :organization do
            xml.oa :name, action.organization_name unless action.organization_name.blank?
            xml.oa :url, action.organization_url unless action.organization_url.blank?
            xml.oa :ein, action.organization_ein unless action.organization_ein.blank?
            xml.oa :email, action.organization_email unless action.organization_email.blank?
          end
        end
      end
    end
    
    if @actions.empty?
      xml.item do
        xml.title  'There are no matching actions at this time.'
        xml.description "type" => "html" do
          xml.text! 'There are no matching actions at this time.'
        end
      end
    end
    
  end
end
