class AddRssaFieldsToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :image_url, :string
    add_column :actions, :subtitle, :text
    add_column :actions, :goal_completed, :float
    add_column :actions, :goal_amount, :float
    add_column :actions, :goal_type, :string
    add_column :actions, :goal_number_of_contributors, :integer
    add_column :actions, :initiator_name, :string
    add_column :actions, :initiator_url, :string
    add_column :actions, :expires_at, :datetime
    add_column :actions, :dcterms_valid, :string
    add_column :actions, :platform_name, :string
    add_column :actions, :platform_url, :string
    add_column :actions, :platform_email, :string
    add_column :actions, :embed_widget, :text
    add_column :actions, :initiator_organization_name, :string
    add_column :actions, :initiator_organization_url, :string
    add_column :actions, :initiator_organization_email, :string
    add_column :actions, :initiator_organization_ein, :string
    add_column :actions, :tags, :text
  end

  def self.down
    remove_column :actions, :image_url
    remove_column :actions, :subtitle
    remove_column :actions, :goal_completed
    remove_column :actions, :goal_amount
    remove_column :actions, :goal_type
    remove_column :actions, :goal_number_of_contributors
    remove_column :actions, :initiator_name
    remove_column :actions, :initiator_url
    remove_column :actions, :expires_at
    remove_column :actions, :dcterms_valid
    remove_column :actions, :platform_name
    remove_column :actions, :platform_url
    remove_column :actions, :platform_email
    remove_column :actions, :embed_widget
    remove_column :actions, :initiator_organization_name
    remove_column :actions, :initiator_organization_url
    remove_column :actions, :initiator_organization_email
    remove_column :actions, :initiator_organization_ein
    remove_column :actions, :tags
  end
end
