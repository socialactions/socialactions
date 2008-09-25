class AddShortUrlToAction < ActiveRecord::Migration
  def self.up
    add_column :actions, :short_url, :string
  end

  def self.down
    remove_column :actions, :short_url
  end
end
