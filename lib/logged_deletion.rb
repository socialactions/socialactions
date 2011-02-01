module LoggedDeletion

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods

    attr_accessor :deleted_record_logger
    
    def get_deleted_record_logger
      if self.deleted_record_logger.nil?
        path = File.join(RAILS_ROOT, "../persistent_logs/deleted_#{self.to_s.underscore.gsub(/\//, '_')}-#{RAILS_ENV}.json")
        self.deleted_record_logger = ActiveSupport::BufferedLogger.new path
        self.deleted_record_logger.auto_flushing = true
      end
      self.deleted_record_logger
    end

  end

  def destroy_and_log
    destroy
    log_deletion
  end

  # Write a status pertaining to the action into the action log
  def log_deletion
    logger = self.class.get_deleted_record_logger
    logger.info "\n# Deleted #{self.class.to_s}##{self.id} at #{Time.now.to_s(:db)}\n"
    logger.info self.to_json
  end

end

require 'shorturl/log'
class Shorturl::Log
	include LoggedDeletion
end
Shorturl::Log.get_deleted_record_logger
