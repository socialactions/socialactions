class AddDisableFields < ActiveRecord::Migration
  def self.up
    rename_column :actions, :blacklisted, :disabled
    add_column :action_sources, :disabled, :boolean, :default => false
    add_column :sites, :disabled, :boolean, :default => false
  end

  def self.down
    rename_column :actions, :disabled, :blacklisted 
    remove_column :action_sources, :disabled
    remove_column :sites, :disabled
  end
end
