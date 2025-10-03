# app/controllers/services/catalog_controller.rb
module Services
  class CatalogController < ApplicationController
    def show
      key         = params[:key]
      folder_path = params[:folder_path].presence || params[:folder].to_s
      slug        = params[:slug]

      if slug.present? && folder_path.present?
        redirect_to service_item_path(key: key, folder_path: folder_path, slug: slug)
      elsif folder_path.present?
        redirect_to service_folder_path(key: key, folder_path: folder_path)
      else
        redirect_to service_index_path(key: key)
      end
    end
  end
end
