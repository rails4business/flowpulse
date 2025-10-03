# app/controllers/services/items_controller.rb
module Services
  class ItemsController < ApplicationController
    before_action :resolve_context

    def index
      # params: :key, :folder_path (opzionale)
      @service_key = params[:key]
      @ctx.service_for_key(@service_key) # 404 se non abilitato per quel subdomain
      @folder_path = (params[:folder_path].presence || @ctx.default_folder).to_s

      case @ctx.data_source_for(@service_key)
      when "db"
        @items = CatalogItem.for_service(@service_key).in_folder(@folder_path).order(:slug)
        @child_folders = child_folders_for(@folder_path, @service_key)
      when "yml"
        # anche i YAML stanno in CatalogItem (importati). Stessa query:
        @items = CatalogItem.for_service(@service_key).in_folder(@folder_path).order(:slug)
        @child_folders = child_folders_for(@folder_path, @service_key)
      else
        @items = []
        @child_folders = []
      end

      @services_tabs = @ctx.active_services_for_subdomain
      @breadcrumb = breadcrumb_for(@folder_path)
    end

    def show
      @service_key = params[:key]
      @folder_path = params[:folder_path].to_s
      @slug        = params[:slug]

      case @ctx.data_source_for(@service_key)
      when "db", "yml"
        @item = CatalogItem.for_service(@service_key)
                           .where(folders_path: @folder_path, slug: @slug)
                           .first!
      else
        head :not_found
      end

      @services_tabs = @ctx.active_services_for_subdomain
      @breadcrumb = breadcrumb_for(@folder_path, tail: @item.title || @slug)
    end

    private

    def resolve_context
      @ctx ||= ContextResolver.new(
        host: request.domain.present? ? [ request.domain, request.tld ].compact.join(".") : request.host,
        subdomain: request.subdomain
      )
      @brand = @ctx.brand
    end

    def breadcrumb_for(folder_path, tail: nil)
      parts = (folder_path.presence || "").split("/")
      crumbs = []
      acc = []
      parts.each do |p|
        acc << p
        crumbs << { name: p, path: service_folder_path(params[:key], folder_path: acc.join("/")) }
      end
      crumbs << { name: tail, path: nil } if tail
      crumbs
    end

    # Calcolo sottocartelle dirette per i TAB “cartelle”
    def child_folders_for(folder_path, service_key)
      base = folder_path.present? ? "#{folder_path}/" : ""
      # trova le immediate child folders
      CatalogItem.for_service(service_key)
                 .where("folders_path LIKE ?", "#{base}%")
                 .pluck(:folders_path)
                 .map { |fp| fp.sub(base, "").split("/").first }
                 .compact
                 .uniq
                 .reject(&:blank?)
                 .sort
    end
  end
end
