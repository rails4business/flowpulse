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

ActiveRecord::Schema[8.0].define(version: 2025_11_01_064911) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "domains", force: :cascade do |t|
    t.string "host"
    t.string "language"
    t.string "title"
    t.text "description"
    t.string "favicon_url"
    t.string "square_logo_url"
    t.string "horizontal_logo_url"
    t.string "provider"
    t.bigint "taxbranch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host"], name: "index_domains_on_host", unique: true
    t.index ["taxbranch_id"], name: "index_domains_on_taxbranch_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "name"
    t.string "surname"
    t.string "username", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "token", null: false
    t.bigint "user_id"
    t.integer "parent_id"
    t.integer "referral_lead_id"
    t.jsonb "meta", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_leads_on_email"
    t.index ["parent_id"], name: "index_leads_on_parent_id"
    t.index ["referral_lead_id"], name: "index_leads_on_referral_lead_id"
    t.index ["token"], name: "index_leads_on_token", unique: true
    t.index ["user_id"], name: "index_leads_on_user_id"
    t.index ["username"], name: "index_leads_on_username", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "taxbranches", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.string "description"
    t.string "slug", null: false
    t.string "slug_category"
    t.string "slug_label"
    t.string "ancestry"
    t.integer "position"
    t.jsonb "meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_taxbranches_on_lead_id"
    t.index ["slug"], name: "index_taxbranches_on_slug", unique: true
    t.index ["slug_category", "slug_label", "slug"], name: "index_taxbranches_on_cat_label_slug_unique", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state_registration", default: 0, null: false
    t.boolean "superadmin", default: false, null: false
    t.bigint "lead_id"
    t.datetime "approved_at"
    t.bigint "approved_by_lead_id"
    t.datetime "last_active_at"
    t.index ["approved_by_lead_id"], name: "index_users_on_approved_by_lead_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["lead_id"], name: "index_users_on_lead_id"
    t.index ["state_registration"], name: "index_users_on_state_registration"
  end

  add_foreign_key "domains", "taxbranches"
  add_foreign_key "leads", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "taxbranches", "leads"
  add_foreign_key "users", "leads"
  add_foreign_key "users", "leads", column: "approved_by_lead_id"
end
