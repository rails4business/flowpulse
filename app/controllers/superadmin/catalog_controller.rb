# app/controllers/superadmin/catalog_controller.rb
class Superadmin::CatalogController < Superadmin::BaseController
  def dashboard
    @stats = {
      total:      CatalogItem.count,
      by_state:   CatalogItem.group(:state).count,
      by_service: CatalogItem.group(:service_key).count
    }
  end

  def import
    CatalogItems::YmlImporter.call
    redirect_to superadmin_catalog_path, notice: "Import completato."
  end

  def import_changed
    CatalogItems::YmlImporter.call(only_changed: true)
    redirect_to superadmin_catalog_path, notice: "Import (solo cambi) completato."
  end

  def rebuild
    ActiveRecord::Base.connection.execute("TRUNCATE catalog_items RESTART IDENTITY CASCADE")
    CatalogItems::YmlImporter.call
    redirect_to superadmin_catalog_path, notice: "Rebuild completato."
  end
end
