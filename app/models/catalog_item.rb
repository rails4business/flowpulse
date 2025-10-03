# app/models/catalog_item.rb
# # Import brands/services in DB (se non lo hai già fatto)
# bin/rails domains:import

# Indicizza i file YML → catalog_items
# bin/rails catalog:index_yml
# oppure tutto (se hai anche servizi DB, che però al momento non usi qui)
# bin/rails catalog:full_index
# YAML importati nel DB (indice)
class CatalogItem < ApplicationRecord
  STATES = %w[draft published archived].freeze

  validates :yml_filename, presence: true, uniqueness: true
  validates :folders_path, :service_key, :slug, presence: true
  validates :state, inclusion: { in: STATES }
  validates :slug, format: { with: /\A[a-z0-9\-]+\z/ }

  # Unicità coerente con indice
  validates :slug, uniqueness: { scope: [ :folders_path, :service_key ] }


  # columns consigliate:
  # brand_id:bigint (opzionale), service_key:string, folders_path:string, slug:string
  # title:string, summary:text, tags:string[], yml_relpath:string
  # source_path:string (per debug), state:string
  # indicizzare: [folders_path, service_key], [slug], trigram su title/summary
  scope :in_folder, ->(path) { where(folders_path: path) }
  scope :for_service, ->(key) { where(service_key: key) }
end
