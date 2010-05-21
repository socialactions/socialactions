class AddIndexToLogsOnActionIds < ActiveRecord::Migration
  def self.up
    # this will speed up the logs/actions JOIN which is done during statisical reports in logs_controller
    add_index :logs, :action_id
  end

  def self.down
    remove_index :logs, :action_id
  end
end
