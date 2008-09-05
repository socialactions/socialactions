class AddNeedsUpdatingToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :needs_updating, :boolean
  end

  def self.down
    remove_column :feeds, :needs_updating
  end
end
