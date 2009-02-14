class CreateShorturlRedirects < ActiveRecord::Migration
  def self.up
    create_table :redirects do |t|
      t.string :cookie
      t.string :url
      t.timestamps
    end
    add_index :redirects, [:id,:cookie,:url], :unique => true
    add_index :redirects, [:cookie,:url], :unique => true
  end

  def self.down
    remove_index :redirects, :column => [:id,:cookie,:url]
    remove_index :redirects, :column => [:cookie,:url]
    drop_table :redirects
  end
end
