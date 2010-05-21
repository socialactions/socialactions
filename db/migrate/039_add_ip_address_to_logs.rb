class AddIpAddressToLogs < ActiveRecord::Migration
  def self.up
    add_column :logs, :ip_address, :string
  end

  def self.down
    remove_column :logs, :ip_address
  end
end
