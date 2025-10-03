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

ActiveRecord::Schema[8.0].define(version: 2025_10_02_145335) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "brand_services", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "service_def_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "service_def_id"], name: "index_brand_services_on_brand_id_and_service_def_id", unique: true
    t.index ["brand_id"], name: "index_brand_services_on_brand_id"
    t.index ["service_def_id"], name: "index_brand_services_on_service_def_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "host", null: false
    t.string "controller_slug", null: false
    t.jsonb "aliases", default: [], null: false
    t.text "description"
    t.string "url_landing"
    t.string "favicon_url"
    t.string "category"
    t.boolean "show_in_home", default: true, null: false
    t.jsonb "seo", default: {}, null: false
    t.text "pages", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host"], name: "index_brands_on_host", unique: true
  end

  create_table "catalog_items", force: :cascade do |t|
    t.string "folders_path", null: false
    t.string "source_path", null: false
    t.string "yml_filename", null: false
    t.string "subdomain"
    t.string "domains", default: [], array: true
    t.string "folder"
    t.integer "position"
    t.string "service_key", null: false
    t.string "slug", null: false
    t.string "version"
    t.string "title"
    t.text "summary"
    t.text "tags", default: [], array: true
    t.string "state", default: "draft", null: false
    t.datetime "published_at"
    t.string "checksum"
    t.jsonb "data", default: {}, null: false
    t.tsvector "tsv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data"], name: "index_catalog_items_on_data", using: :gin
    t.index ["folders_path"], name: "index_catalog_items_on_folders_path"
    t.index ["published_at"], name: "index_catalog_items_on_published_at"
    t.index ["service_key", "slug"], name: "idx_catalog_items_unique_service_slug", unique: true
    t.index ["service_key"], name: "index_catalog_items_on_service_key"
    t.index ["slug"], name: "index_catalog_items_on_slug"
    t.index ["state"], name: "index_catalog_items_on_state"
    t.index ["tags"], name: "index_catalog_items_on_tags", using: :gin
    t.index ["tsv"], name: "index_catalog_items_on_tsv", using: :gin
    t.index ["yml_filename"], name: "index_catalog_items_on_yml_filename"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "cover_url"
    t.string "video_url"
    t.text "body"
    t.datetime "published_at"
    t.integer "visibility", default: 0, null: false
    t.integer "state", default: 0, null: false
    t.string "slug", null: false
    t.string "domains", default: [], array: true
    t.string "folder_path"
    t.string "subdomain"
    t.string "service_key", default: "blog", null: false
    t.integer "position"
    t.string "tags", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domains"], name: "index_posts_on_domains", using: :gin
    t.index ["folder_path"], name: "index_posts_on_folder_path"
    t.index ["published_at"], name: "index_posts_on_published_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["subdomain", "service_key"], name: "index_posts_on_subdomain_and_service_key"
    t.index ["tags"], name: "index_posts_on_tags", using: :gin
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "service_defs", force: :cascade do |t|
    t.string "key", null: false
    t.string "subdomain", null: false
    t.string "original_domain"
    t.string "title"
    t.text "description"
    t.string "image_url"
    t.string "state", default: "develop", null: false
    t.string "data_source", default: "yml", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_service_defs_on_key", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "superadmin", default: false, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["superadmin"], name: "index_users_on_superadmin"
  end

  add_foreign_key "brand_services", "brands"
  add_foreign_key "brand_services", "service_defs"
  add_foreign_key "posts", "users"
  add_foreign_key "sessions", "users"
end
