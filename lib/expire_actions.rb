module ExpireActions
  
  DEFAULT_LIFESPAN = 90
  
  def self.go
    action_sources = ActionSource.find(:all)
    action_sources.each do |action_source|
      self.expire_actions_by_dcterms_valid(action_source)
      self.expire_actions_by_action_lifespan(action_source)
    end
  end
  
  def self.expire_actions_by_dcterms_valid(action_source)
    actions = action_source.actions.find(:all, :conditions => 'dcterms_valid IS NOT NULL')
    actions.each do |action|
      if !action.disabled && (action.dcterms_valid.to_date <= DateTime.now)
         action.disabled = true
         action.save
      end
    end
  end
    
  def self.expire_actions_by_action_lifespan(action_source)
    actions = action_source.actions.find(:all, :conditions => 'dcterms_valid IS NULL')
    lifespan = action_source.action_lifespan || DEFAULT_LIFESPAN
    actions.each do |action|
      create_date = action.created_at || action.updated_at || DateTime.now
      if !action.disabled && ((DateTime.now.to_date - create_date.to_date).days >= lifespan.days)
         action.disabled = true
         action.save
      end
    end
  end

end