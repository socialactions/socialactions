class AddBlacklistFields < ActiveRecord::Migration
  def self.up
    add_column :actions, :blacklisted, :boolean
    add_column :sites, :abuse_email, :string
  end

  def self.down
    remove_column :actions, :blacklisted
    remove_column :sites, :abuse_email
  end
end
