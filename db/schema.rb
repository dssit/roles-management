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

ActiveRecord::Schema.define(version: 20180308005801) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_key_users", id: :serial, force: :cascade do |t|
    t.string "secret", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", limit: 255
    t.datetime "logged_in_at"
    t.index ["name", "secret"], name: "index_api_key_users_on_name_and_secret"
  end

  create_table "api_whitelisted_ip_users", id: :serial, force: :cascade do |t|
    t.string "address", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "reason"
    t.datetime "logged_in_at"
    t.index ["address"], name: "index_api_whitelisted_ip_users_on_address"
  end

  create_table "application_operatorships", id: :serial, force: :cascade do |t|
    t.integer "application_id"
    t.integer "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.index ["application_id", "entity_id", "parent_id"], name: "idx_app_operatorships_on_app_id_and_entity_id_and_parent_id"
  end

  create_table "application_ownerships", id: :integer, force: :cascade do |t|
    t.integer "entity_id"
    t.integer "application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
  end

  create_table "applications", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "url", limit: 255
    t.index ["name"], name: "index_applications_on_name"
  end

  create_table "business_office_units", force: :cascade do |t|
    t.string "org_oid"
    t.string "dept_code"
    t.string "dept_official_name"
    t.string "dept_display_name"
    t.string "dept_abbrev"
    t.boolean "is_ucdhs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "departments", force: :cascade do |t|
    t.string "code", null: false
    t.string "officialName", null: false
    t.string "displayName", null: false
    t.string "abbreviation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bou_org_oid"
  end

  create_table "entities", id: :serial, force: :cascade do |t|
    t.string "type", limit: 255
    t.string "name", limit: 255
    t.string "first", limit: 255
    t.string "last", limit: 255
    t.string "email", limit: 255
    t.string "loginid", limit: 255
    t.boolean "active", default: true
    t.string "phone", limit: 255
    t.string "address", limit: 255
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "logged_in_at"
    t.boolean "is_employee"
    t.boolean "is_hs_employee"
    t.boolean "is_faculty"
    t.boolean "is_student"
    t.boolean "is_staff"
    t.boolean "is_external"
    t.integer "iam_id"
    t.datetime "synced_at"
    t.index ["id"], name: "index_entities_on_id"
    t.index ["loginid"], name: "index_entities_on_loginid"
    t.index ["name"], name: "index_entities_on_name"
    t.index ["type"], name: "index_entities_on_type"
  end

  create_table "group_memberships", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_operatorships", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "entity_id"
  end

  create_table "group_ownerships", id: :integer, force: :cascade do |t|
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "entity_id"
  end

  create_table "group_rule_result_sets", force: :cascade do |t|
    t.string "column"
    t.boolean "condition"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_rule_results", id: :serial, force: :cascade do |t|
    t.integer "group_rule_result_set_id"
    t.integer "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_rules", id: :serial, force: :cascade do |t|
    t.string "column", limit: 255
    t.string "condition", limit: 255
    t.string "value", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
    t.integer "group_rule_result_set_id"
  end

  create_table "majors", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_majors_on_name"
  end

  create_table "person_favorite_assignments", id: :serial, force: :cascade do |t|
    t.integer "entity_id"
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pps_associations", force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "title_id", null: false
    t.integer "department_id", null: false
    t.integer "association_rank", null: false
    t.integer "position_type_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "admin_department_id"
    t.integer "appt_department_id"
  end

  create_table "role_assignments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role_id"
    t.integer "entity_id"
    t.integer "parent_id"
    t.index ["role_id", "entity_id", "parent_id"], name: "index_role_assignments_on_role_id_and_entity_id_and_parent_id"
    t.index ["role_id", "entity_id"], name: "index_role_assignments_on_role_id_and_entity_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "token", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "application_id"
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.string "ad_path", limit: 255
    t.datetime "last_ad_sync"
    t.string "ad_guid", limit: 255
    t.index ["id"], name: "index_roles_on_id"
  end

  create_table "sis_associations", force: :cascade do |t|
    t.integer "major_id"
    t.integer "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "level_code", limit: 2
    t.integer "association_rank"
  end

  create_table "titles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "code", limit: 255
    t.string "unit", limit: 3
    t.index ["code"], name: "index_titles_on_code"
  end

  create_table "tracked_items", force: :cascade do |t|
    t.string "kind"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
