class CreateCatalogItems < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")
    enable_extension "btree_gin" unless extension_enabled?("btree_gin")

    create_table :catalog_items do |t|
      t.string   :brand_slug,    null: false
      t.string   :folders_path
      t.string   :service_key,   null: false
      t.string   :slug,          null: false
      t.string   :title
      t.text     :summary

      # 👇 qui lo trasformi in array
      t.text     :tags, array: true, default: []

      t.string   :state,         null: false, default: "draft"
      t.string   :source_path
      t.string   :checksum
      t.string   :version
      t.datetime :published_at
      t.jsonb    :data,          null: false, default: {}
      t.tsvector :tsv

      t.timestamps
    end

    add_index :catalog_items, [ :brand_slug, :service_key, :slug ],
              unique: true, name: "idx_catalog_items_uniqueness"
    add_index :catalog_items, :tags, using: :gin
    add_index :catalog_items, :data, using: :gin
    add_index :catalog_items, :state
    add_index :catalog_items, :published_at
    add_index :catalog_items, :folders_path
    add_index :catalog_items, :tsv, using: :gin
  end
end
