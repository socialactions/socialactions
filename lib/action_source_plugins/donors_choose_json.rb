module DonorsChooseJson

  def json
    @json ||= ActiveSupport::JSON.decode(open(url, 'User-Agent' => 'SocialActions').read)
  end
  
  def parse
    json['proposals'].each do |proposal|
      action = actions.find_or_create_by_url(proposal['proposalURL'])
      action.expires_at = proposal['expirationDate']
      action.dcterms_valid = "end=" + proposal['expirationDate'].xmlschema
      action.description = proposal['shortDescription']
      action.title = proposal['title']
      action.goal_amount = proposal['totalPrice']
      action.goal_completed = proposal['totalPrice'].to_f - proposal['costToComplete'].to_f #NOTE: should be alreadyGiven, but it doesn't look like they're actually providing this field...
      action.goal_type = 'USD'
      action.initiator_name = proposal['teacherName']
      action.organization_name = proposal['schoolName']
      action.image_url = proposal['imageURL']
      action.subtitle = proposal['fulfillmentTrailer']

      action.extract_entities
      
      action.save!
    end
    
  end

end
