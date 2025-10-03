# frozen_string_literal: true

module Services
  module Flowpulse
    class LessonsController < ApplicationController
      before_action :resolve_ctx
      before_action -> { ensure_service!("onlinecourses") }

      def show
        @service_key  = "onlinecourses"
        @content_slug = params[:content_slug].to_s
        @lesson_slug  = params[:lesson_slug].to_s

        # 1) Trova il CatalogItem del corso: per content_slug in data["course"]["content_slug"],
        #    con fallback sullo slug dell'item
        @course_item = CatalogItem.for_service(@service_key)
                                  .where("data -> 'course' ->> 'content_slug' = ?", @content_slug)
                                  .first
        @course_item ||= CatalogItem.for_service(@service_key).find_by!(slug: @content_slug)

        # 2) Carica la struttura del corso (dal JSONB o YAML)
        @course = Onlinecourses::YamlCourseLoader.load_from_item(@course_item)

        # 3) Trova la lezione
        @lesson = Array(@course.lessons).find { |l| l["slug"] == @lesson_slug }
        raise ActiveRecord::RecordNotFound, "Lesson not found" unless @lesson

        # 4) Carica il post collegato (preferenza: id; fallback: slug)
        @post =
          if @lesson["post_id"].present?
            Post.find_by(id: @lesson["post_id"])
          elsif @lesson["post_slug"].present?
            Post.find_by(slug: @lesson["post_slug"])
          else
            nil
          end

        # 5) breadcrumb e tabs
        @services_tabs = @ctx.active_services_for_subdomain || []
        @breadcrumb    = breadcrumbs_for_course(@course_item, @course, @lesson)
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

      def breadcrumbs_for_course(course_item, course, lesson)
        base_path = flowpulse_onlinecourses_item_in_folder_path(folder_path: course_item.folders_path, slug: course_item.slug)
        [
          { name: "Onlinecourses", path: flowpulse_onlinecourses_index_path },
          { name: (course.title || course_item.slug), path: base_path },
          { name: (lesson["title"].presence || lesson["slug"].to_s.humanize), path: nil }
        ]
      end
    end
  end
end
