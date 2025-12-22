# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2018_06_14_154832) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "project_content_items", id: :serial, force: :cascade do |t|
    t.string "url"
    t.string "title"
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "project_id"
    t.boolean "done", default: false
    t.uuid "content_id"
    t.integer "flag"
    t.string "suggested_tags"
    t.text "need_help_comment"
    t.index ["content_id"], name: "index_project_content_items_on_content_id", unique: true
    t.index ["flag"], name: "index_project_content_items_on_flag"
    t.index ["project_id"], name: "index_project_content_items_on_project_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "taxonomy_branch"
    t.boolean "bulk_tagging_enabled", default: false
  end

  create_table "tag_mappings", id: :serial, force: :cascade do |t|
    t.integer "tagging_source_id", null: false
    t.string "content_base_path", null: false
    t.string "link_title"
    t.string "link_content_id", null: false
    t.string "link_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "publish_requested_at", precision: nil
    t.datetime "publish_completed_at", precision: nil
    t.string "state", null: false
    t.string "messages"
    t.string "tagging_source_type"
    t.index ["tagging_source_id"], name: "index_tag_mappings_on_tagging_source_id"
  end

  create_table "tag_migrations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "source_content_id"
    t.string "state"
    t.datetime "last_published_at", precision: nil
    t.string "last_published_by"
    t.datetime "deleted_at", precision: nil
    t.string "error_message"
    t.boolean "delete_source_link", default: false
    t.string "source_title"
    t.string "source_document_type"
  end

  create_table "tagging_spreadsheets", id: :serial, force: :cascade do |t|
    t.string "url", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "user_uid", null: false
    t.string "last_published_by"
    t.datetime "last_published_at", precision: nil
    t.string "state", null: false
    t.text "error_message"
    t.datetime "deleted_at", precision: nil
    t.string "description"
  end

  create_table "taxonomy_health_warnings", force: :cascade do |t|
    t.uuid "content_id"
    t.string "title"
    t.string "internal_name"
    t.string "path"
    t.string "metric"
    t.text "message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "value"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.text "permissions"
    t.boolean "remotely_signed_out"
    t.boolean "disabled"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "content_id", null: false
    t.integer "number", null: false
    t.json "object_changes"
    t.text "note"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["content_id", "number"], name: "index_versions_on_content_id_and_number", unique: true
  end

  add_foreign_key "project_content_items", "projects"
end
