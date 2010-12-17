module ExpireActions

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods

    def expire_actions
			# Note: dcterms expirations were implemented but never tested
      #self.expire_actions_by_dcterms_valid
      self.expire_actions_by_action_lifespan
      self.delete_long_expired_actions
    end

    def expire_actions_by_dcterms_valid
      actions = Action.scoped(:conditions => 'dcterms_valid IS NOT NULL')
      actions.all.each do |action|
        if !action.disabled && (action.dcterms_valid.to_date <= DateTime.now)
           action.disabled = true
           action.save!
        end
      end
      actions
    end

    def expire_actions_by_action_lifespan
      # Disable an actions past their expiration date
      actions = Action.expired.all
			actions.each do |action|
        action.disabled = true
        action.save!
      end
      actions
    end

    def delete_long_expired_actions
      # Delete and log any actions that were disabled more than 30 days ago
      actions = Action.long_disabled.all
			actions.each do |action|
        action.destroy_and_log
      end
      actions
    end
    
  end

end
