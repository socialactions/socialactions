module ActionsHelper

  def edit_entity_path action, entity_type, entity
    args = {
      'entity[type]' => entity_type,
      'entity[name]' => entity['name']
    }
    args.merge!({
      'entity[latitude]' => entity['latitude'],
      'entity[longitude]' => entity['longitude']
    }) if entity_type == 'geolocations'
    
    edit_entity_action_path(action) + '?' + args.map{|k, v| "#{k}=#{v}"}.join('&')
  end

end
