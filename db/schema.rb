# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160810153418) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "tag_mappings", force: :cascade do |t|
    t.integer  "tagging_spreadsheet_id"
    t.string   "content_base_path"
    t.string   "link_title"
    t.string   "link_content_id"
    t.string   "link_type"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "publish_requested_at"
    t.datetime "publish_completed_at"
  end

  add_index "tag_mappings", ["tagging_spreadsheet_id"], name: "index_tag_mappings_on_tagging_spreadsheet_id", using: :btree

  create_table "tagging_spreadsheets", force: :cascade do |t|
    t.string   "url",               null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "user_uid"
    t.string   "last_published_by"
    t.datetime "last_published_at"
    t.string   "description"
    t.string   "state",             null: false
    t.text     "error_message"
    t.datetime "deleted_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.string   "organisation_slug"
    t.string   "organisation_content_id"
    t.text     "permissions"
    t.boolean  "remotely_signed_out"
    t.boolean  "disabled"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_foreign_key "tag_mappings", "tagging_spreadsheets", on_delete: :cascade
end
