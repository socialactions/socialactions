class AddActionsUrlIndex < ActiveRecord::Migration
  def self.up
    add_index :actions, :url
  end

  def self.down
    remove_index :actions, :url
  end
end
