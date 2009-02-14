class CreateShorturlLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.string :referrer
      t.references :redirect
      t.timestamps
    end
    add_index :logs, [:redirect_id,:referrer], :unique => false
  end

  def self.down
    remove_index :logs, [:redirect_id,:referrer]
    drop_table :logs
  end
end
