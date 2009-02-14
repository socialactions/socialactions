class AddActionIndexes < ActiveRecord::Migration
  def self.up
    add_index :actions, :redirect_id, :unique => false
    add_index :actions, :id, :unique => true
  end

  def self.down
    remove_index :actions, :id
    remove_index :actions, :redirect_id
  end
end
