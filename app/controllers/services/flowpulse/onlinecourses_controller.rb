# app/controllers/services/flowpulse/onlinecourses_controller.rb
require "ostruct"
module Services
  module Flowpulse
    class OnlinecoursesController < ApplicationController
      allow_unauthenticated_access
      # ... (il resto invariato)
      before_action :resolve_ctx
      before_action -> { ensure_service!("onlinecourses") }

      # ⬇️ QUESTA AZIONE SERVE per /onlinecourses
      def index
        @service_key   = "onlinecourses"
        @folder_path   = (params[:folder_path].presence || @ctx.default_folder).to_s

        @items         = CatalogItem.for_service(@service_key)
                                    .where(folders_path: @folder_path)
                                    .order(:slug)
        @child_folders = child_folders_for(@folder_path, @service_key)
        @services_tabs = @ctx.active_services_for_subdomain
        @breadcrumb    = breadcrumb_for(@folder_path)
      end
      def show
        @service_key = "onlinecourses"
        slug     = params[:slug].to_s
        fp_param = params[:folder_path].to_s.presence

        # Trova l'item (oppure 404)
        @item =
          if fp_param.present?
            CatalogItem.for_service(@service_key).find_by!(folders_path: fp_param, slug: slug)
          else
            base = @ctx.default_folder.to_s
            CatalogItem.for_service(@service_key)
                       .where(slug: slug)
                       .where("folders_path = ? OR folders_path LIKE ?", base, "#{base}/%")
                       .order(Arel.sql("CASE WHEN folders_path = '#{base}' THEN 0 ELSE 1 END"))
                       .first!
          end
        @folder_path = @item.folders_path

        # Carica il corso; se qualcosa fallisce o torna nil, crea un fallback
        begin
          course_obj = Onlinecourses::YamlCourseLoader.load_from_item(@item)
        rescue => e
          Rails.logger.error("[Onlinecourses#show] loader error item=#{@item.id} #{e.class}: #{e.message}")
          course_obj = nil
        end

        @course = course_obj || OpenStruct.new(
          content_slug:  (@item.slug || slug).to_s,
          title:         (@item.title.presence || slug.humanize),
          description:   @item.summary.to_s,
          cover_url:     nil,
          preparatory_courses: [],
          lessons: []
        )

        @services_tabs = @ctx.active_services_for_subdomain || []
        @breadcrumb    = breadcrumb_for(@folder_path, tail: (@item.title.presence || slug))
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      private

      def resolve_ctx
        @ctx   = ContextResolver.new(request: request)
        @brand = @ctx.brand
      end

      def ensure_service!(key)
        @ctx.service_for_key(key) # 404 se non attivo su questo subdomain
      end

      def breadcrumb_for(folder_path, tail: nil)
        parts = (folder_path.presence || "").split("/")
        acc   = []
        crumbs = parts.map do |p|
          acc << p
          { name: p, path: flowpulse_onlinecourses_folder_path(folder_path: acc.join("/")) }
        end
        crumbs << { name: tail, path: nil } if tail
        crumbs
      end

      def child_folders_for(folder_path, service_key)
        base = folder_path.to_s
        CatalogItem.for_service(service_key)
                   .where("folders_path LIKE ?", base.blank? ? "%" : "#{base}/%")
                   .pluck(:folders_path)
                   .map { |fp| base.blank? ? fp.split("/").first : fp.sub("#{base}/", "").split("/").first }
                   .compact.uniq.sort
      end
      def show
        @service_key = "onlinecourses"
        slug         = params[:slug].to_s
        fp_param     = params[:folder_path].to_s.presence

        if fp_param.present?
          @item        = CatalogItem.for_service(@service_key).find_by!(folders_path: fp_param, slug: slug)
          @folder_path = @item.folders_path
        else
          base = @ctx.default_folder.to_s
          @item = CatalogItem.for_service(@service_key)
                             .where(slug: slug)
                             .where("folders_path = ? OR folders_path LIKE ?", base, "#{base}/%")
                             .order(Arel.sql("CASE WHEN folders_path = '#{base}' THEN 0 ELSE 1 END"))
                             .first!
          @folder_path = @item.folders_path
        end

        # 👉 carica struttura corso dal JSONB o dal file YAML
        @course = Onlinecourses::YamlCourseLoader.load_from_item(@item)

        @services_tabs = @ctx.active_services_for_subdomain
        @breadcrumb    = breadcrumb_for(@folder_path, tail: (@item.title.presence || slug))

        fresh_when(etag: [ @service_key, @folder_path, @item.id, @item.updated_at ],
                   last_modified: @item.updated_at,
                   public: true)
      end
    end
  end
end
