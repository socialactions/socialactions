class CreateApiKeys < ActiveRecord::Migration
  def self.up
    create_table :api_keys do |t|
      t.string :name
      t.string :host_domain
      t.string :key

      t.timestamps
    end
    add_index :api_keys, :key, :unique => true
  end

  def self.down
    remove_index :api_keys, :key
    drop_table :api_keys
  end
end
