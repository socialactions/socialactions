class ChangeInitiatorOrgToJustOrg < ActiveRecord::Migration
  def self.up
    rename_column :actions, :initiator_organization_name, :organization_name
    rename_column :actions, :initiator_organization_url, :organization_url
    rename_column :actions, :initiator_organization_email, :organization_email
    rename_column :actions, :initiator_organization_ein, :organization_ein
  end

  def self.down
    rename_column :actions, :organization_name, :initiator_organization_name
    rename_column :actions, :organization_url, :initiator_organization_url
    rename_column :actions, :organization_email, :initiator_organization_email
    rename_column :actions, :organization_ein, :initiator_organization_ein
  end
end
