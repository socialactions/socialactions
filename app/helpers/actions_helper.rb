module ActionsHelper

  # Use the short_url if present
  # Note:
  #   REDIRECT_PREFIX is defined in config/environments/{env}.rb
  #   Idea is to have a different (sub)domain for these short URI's
  def proxy_action_url action
    action.short_url.present? ? REDIRECT_PREFIX + action.short_url : action.url
  end

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
