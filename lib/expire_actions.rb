module ExpireActions

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods

#    do not delete long expired actions anymore
#    def expire_actions
#			# Note: dcterms expirations were implemented but never tested
#      #self.expire_actions_by_dcterms_valid
#      actions = self.expire_actions
#			p "Expired #{actions.count} actions"
#      actions = self.delete_long_expired_actions
#			p "Deleted #{actions.count} long-expired actions"
#    end

    def expire_actions
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
