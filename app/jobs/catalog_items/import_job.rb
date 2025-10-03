# app/jobs/catalog_items/import_job.rb
class CatalogItems::ImportJob < ApplicationJob
  queue_as :default
  def perform(brand_host:, folders:, key:)
    brand = DomainRegistry.brand_for_host(brand_host)
    CatalogItems::Importer.call(brand:, folders:, key:)
  end
end
