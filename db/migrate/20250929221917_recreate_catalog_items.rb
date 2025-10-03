# db/migrate/XXXXXXXXXXXXXX_recreate_catalog_items.rb
class RecreateCatalogItems < ActiveRecord::Migration[7.2]
  def up
    drop_table :catalog_items, if_exists: true

    enable_extension "pg_trgm"   unless extension_enabled?("pg_trgm")
    enable_extension "btree_gin" unless extension_enabled?("btree_gin")

    create_table :catalog_items do |t|
      # Provenienza nel filesystem YAML
      t.string   :folders_path, null: false        # es. "01_salute/01_posturacorretta/01_postura-e-fisiologia"
      t.string   :source_path,  null: false        # es. "01_salute/.../01-igiene-posturale_onlinecourses_v2024_09_22.yml"
      t.string   :yml_filename, null: false       # es. "01-igiene-posturale_onlinecourses_v2024_09_22.yml"

      # Visibilità e scoping multi-host
      t.string   :subdomain                         # es. "flowpulse" (nil => qualunque)
      t.string   :domains,    array: true, default: [] # es. ["posturacorretta.org"] (vuoto => qualunque)
      t.string   :folder
      # Identità logica dell’item
      t.integer  :position                          # da prefissi "01_", "02_", ...
      t.string   :service_key, null: false         # es. "onlinecourses" | "teaching" | "questionnaire"
      t.string   :slug,        null: false         # es. "igiene-posturale"

      # Metadati editoriali
      t.string   :version                            # es. "v2024_09_22" (se presente nel filename)
      t.string   :title
      t.text     :summary
      t.text     :tags, array: true, default: []

      # Stato di pubblicazione
      t.string   :state,       null: false, default: "draft" # "draft" | "published" | "archived"
      t.datetime :published_at

      # Integrità contenuto e ricerca
      t.string   :checksum
      t.jsonb    :data,       null: false, default: {}
      t.tsvector :tsv

      t.timestamps
    end

    # Unicità forte per origine file
    add_index :catalog_items, :yml_filename
    add_index :catalog_items, [ :service_key, :slug ], unique: true, name: "idx_catalog_items_unique_service_slug"
    # Indici utili per filtri e listing
    add_index :catalog_items, :folders_path
    add_index :catalog_items, :service_key
    add_index :catalog_items, :slug
    add_index :catalog_items, :state
    add_index :catalog_items, :published_at

    # Ricerca/filtri avanzati
    add_index :catalog_items, :tags, using: :gin
    add_index :catalog_items, :data, using: :gin
    add_index :catalog_items, :tsv,  using: :gin
  end

  def down
    drop_table :catalog_items, if_exists: true
  end
end
