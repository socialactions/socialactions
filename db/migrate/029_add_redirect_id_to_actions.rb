class AddRedirectIdToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :redirect_id, :integer
    add_column :actions, :hit_count, :integer, :default => 0
  end

  def self.down
    remove_column :actions, :redirect_id
    remove_column :actions, :hit_count
  end
end
