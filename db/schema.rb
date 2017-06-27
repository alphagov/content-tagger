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

ActiveRecord::Schema.define(version: 20170627094157) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "tagging_events", force: :cascade do |t|
    t.uuid     "taxon_content_id",                       null: false
    t.string   "taxon_title",                            null: false
    t.uuid     "taggable_content_id",                    null: false
    t.string   "taggable_title",                         null: false
    t.uuid     "user_uid"
    t.date     "tagged_on",                              null: false
    t.datetime "tagged_at",                              null: false
    t.integer  "change",                                 null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "taggable_navigation_document_supertype", null: false
    t.string   "taggable_base_path",                     null: false
    t.string   "user_name"
    t.string   "user_organisation"
    t.index ["taggable_content_id"], name: "index_tagging_events_on_taggable_content_id", using: :btree
    t.index ["tagged_on"], name: "index_tagging_events_on_tagged_on", using: :btree
    t.index ["taxon_content_id"], name: "index_tagging_events_on_taxon_content_id", using: :btree
    t.index ["user_name"], name: "index_tagging_events_on_user_name", using: :btree
    t.index ["user_organisation"], name: "index_tagging_events_on_user_organisation", using: :btree
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

end
