class CreateActionSources < ActiveRecord::Migration
  def self.up
    create_table :action_sources do |t|
      t.string :name
      t.string :url
      t.datetime :last_accessed
      t.integer :site_id
      t.integer :action_type_id
      t.boolean :needs_updating
      t.string :plugin_name
      t.text :additional_data

      t.timestamps
    end
    rename_column :actions, :feed_id, :action_source_id
  end

  def self.down
    drop_table :action_sources
  end
end
