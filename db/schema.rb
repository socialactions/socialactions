# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 22) do

  create_table "action_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "action_types", ["id", "name"], :name => "index_action_types_on_id_and_name", :unique => true
  add_index "action_types", ["name"], :name => "index_action_types_on_name", :unique => true

  create_table "actions", :force => true do |t|
    t.text     "description"
    t.string   "url"
    t.text     "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feed_id"
    t.decimal  "latitude",                     :precision => 15, :scale => 10
    t.decimal  "longitude",                    :precision => 15, :scale => 10
    t.string   "location"
    t.integer  "site_id"
    t.integer  "action_type_id"
    t.string   "short_url"
    t.string   "image_url"
    t.text     "subtitle"
    t.float    "goal_completed"
    t.float    "goal_amount"
    t.string   "goal_type"
    t.integer  "goal_number_of_contributors"
    t.string   "initiator_name"
    t.string   "initiator_url"
    t.string   "initiator_email"
    t.datetime "expires_at"
    t.string   "dcterms_valid"
    t.string   "platform_name"
    t.string   "platform_url"
    t.string   "platform_email"
    t.text     "embed_widget"
    t.string   "initiator_organization_name"
    t.string   "initiator_organization_url"
    t.string   "initiator_organization_email"
    t.string   "initiator_organization_ein"
    t.text     "tags"
  end

  add_index "actions", ["url"], :name => "index_actions_on_url"

  create_table "feeds", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "last_accessed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag_finder"
    t.integer  "site_id"
    t.string   "location_finder"
    t.integer  "action_type_id"
    t.boolean  "needs_updating"
    t.boolean  "is_donorschoose_json", :default => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
