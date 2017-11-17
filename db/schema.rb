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

ActiveRecord::Schema.define(version: 20171106134207) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "project_content_items", force: :cascade do |t|
    t.string   "url"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "project_id"
    t.boolean  "done",              default: false
    t.uuid     "content_id"
    t.integer  "flag"
    t.string   "suggested_tags"
    t.text     "need_help_comment"
    t.index ["content_id"], name: "index_project_content_items_on_content_id", unique: true, using: :btree
    t.index ["flag"], name: "index_project_content_items_on_flag", using: :btree
    t.index ["project_id"], name: "index_project_content_items_on_project_id", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.uuid     "taxonomy_branch"
    t.boolean  "bulk_tagging_enabled", default: false
  end

  create_table "tag_mappings", force: :cascade do |t|
    t.integer  "tagging_source_id",    null: false
    t.string   "content_base_path",    null: false
    t.string   "link_title"
    t.string   "link_content_id",      null: false
    t.string   "link_type",            null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "publish_requested_at"
    t.datetime "publish_completed_at"
    t.string   "state",                null: false
    t.string   "messages"
    t.string   "tagging_source_type"
    t.index ["tagging_source_id"], name: "index_tag_mappings_on_tagging_source_id", using: :btree
  end

  create_table "tag_migrations", force: :cascade do |t|
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "source_content_id"
    t.string   "state"
    t.datetime "last_published_at"
    t.string   "last_published_by"
    t.datetime "deleted_at"
    t.string   "error_message"
    t.boolean  "delete_source_link",   default: false
    t.string   "source_title"
    t.string   "source_document_type"
  end

  create_table "tagging_spreadsheets", force: :cascade do |t|
    t.string   "url",               null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "user_uid",          null: false
    t.string   "last_published_by"
    t.datetime "last_published_at"
    t.string   "state",             null: false
    t.text     "error_message"
    t.datetime "deleted_at"
    t.string   "description"
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

  add_foreign_key "project_content_items", "projects"
end
