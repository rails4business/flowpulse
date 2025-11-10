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

ActiveRecord::Schema[8.1].define(version: 2025_11_10_102920) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "favicon_url"
    t.string "horizontal_logo_url"
    t.string "host"
    t.string "language"
    t.string "provider"
    t.string "square_logo_url"
    t.bigint "taxbranch_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["host"], name: "index_domains_on_host", unique: true
    t.index ["taxbranch_id"], name: "index_domains_on_taxbranch_id"
  end

  create_table "eventdates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cycle"
    t.datetime "date_end"
    t.datetime "date_start"
    t.text "description"
    t.bigint "lead_id", null: false
    t.jsonb "meta"
    t.integer "status"
    t.bigint "taxbranch_id", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_eventdates_on_lead_id"
    t.index ["taxbranch_id"], name: "index_eventdates_on_taxbranch_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "leads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.jsonb "meta", default: {}
    t.string "name"
    t.integer "parent_id"
    t.string "phone"
    t.integer "referral_lead_id"
    t.string "surname"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "username", null: false
    t.index ["email"], name: "index_leads_on_email"
    t.index ["parent_id"], name: "index_leads_on_parent_id"
    t.index ["referral_lead_id"], name: "index_leads_on_referral_lead_id"
    t.index ["token"], name: "index_leads_on_token", unique: true
    t.index ["user_id"], name: "index_leads_on_user_id"
    t.index ["username"], name: "index_leads_on_username", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.string "banner_url"
    t.text "content"
    t.text "content_md"
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "lead_id", null: false
    t.jsonb "meta", default: {}
    t.datetime "published_at"
    t.datetime "scheduled_at"
    t.string "slug"
    t.integer "status", default: 0
    t.integer "taxbranch_id"
    t.string "thumb_url"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url_media_content"
    t.index ["lead_id"], name: "index_posts_on_lead_id"
    t.index ["meta"], name: "index_posts_on_meta", using: :gin
    t.index ["published_at"], name: "index_posts_on_published_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["taxbranch_id"], name: "index_posts_on_taxbranch_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tag_positionings", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.bigint "lead_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.bigint "taxbranch_id", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_tag_positionings_on_lead_id"
    t.index ["metadata"], name: "index_tag_positionings_on_metadata", using: :gin
    t.index ["taxbranch_id", "category", "name"], name: "index_tag_positionings_on_taxbranch_id_and_category_and_name", unique: true
    t.index ["taxbranch_id", "category"], name: "index_tag_positionings_on_taxbranch_id_and_category"
    t.index ["taxbranch_id"], name: "index_tag_positionings_on_taxbranch_id"
  end

  create_table "taxbranches", force: :cascade do |t|
    t.string "ancestry"
    t.datetime "created_at", null: false
    t.string "description"
    t.boolean "home_nav", default: false
    t.bigint "lead_id", null: false
    t.jsonb "meta"
    t.integer "position"
    t.boolean "positioning_tag_public", default: false, null: false
    t.string "slug", null: false
    t.string "slug_category"
    t.string "slug_label"
    t.datetime "updated_at", null: false
    t.index ["home_nav"], name: "index_taxbranches_on_home_nav"
    t.index ["lead_id"], name: "index_taxbranches_on_lead_id"
    t.index ["positioning_tag_public"], name: "index_taxbranches_on_positioning_tag_public"
    t.index ["slug"], name: "index_taxbranches_on_slug", unique: true
    t.index ["slug_category", "slug_label", "slug"], name: "index_taxbranches_on_cat_label_slug_unique", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "approved_by_lead_id"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.integer "invites_count", default: 0, null: false
    t.integer "invites_limit", default: 7, null: false
    t.datetime "last_active_at"
    t.bigint "lead_id"
    t.string "password_digest", null: false
    t.integer "referrer_id"
    t.integer "state_registration", default: 0, null: false
    t.boolean "superadmin", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_lead_id"], name: "index_users_on_approved_by_lead_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["lead_id"], name: "index_users_on_lead_id"
    t.index ["referrer_id"], name: "index_users_on_referrer_id"
    t.index ["state_registration"], name: "index_users_on_state_registration"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "domains", "taxbranches"
  add_foreign_key "eventdates", "leads"
  add_foreign_key "eventdates", "taxbranches"
  add_foreign_key "leads", "users"
  add_foreign_key "posts", "leads"
  add_foreign_key "sessions", "users"
  add_foreign_key "tag_positionings", "leads"
  add_foreign_key "tag_positionings", "taxbranches"
  add_foreign_key "taxbranches", "leads"
  add_foreign_key "users", "leads"
  add_foreign_key "users", "leads", column: "approved_by_lead_id"
end
