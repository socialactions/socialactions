class AddActionIdToLogs < ActiveRecord::Migration
  def self.up
    add_column :logs, :action_id, :integer
  end

  def self.down
    remove_column :logs, :action_id
  end
end
