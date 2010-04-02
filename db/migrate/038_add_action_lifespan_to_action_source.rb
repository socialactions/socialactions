class AddActionLifespanToActionSource < ActiveRecord::Migration
  def self.up
    add_column :action_sources, :action_lifespan, :integer
  end

  def self.down
    remove_column :action_sources, :action_lifespan
  end
end
