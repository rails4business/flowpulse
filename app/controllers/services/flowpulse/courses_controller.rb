module Services
  module Flowpulse
    class CoursesController < ApplicationController
      before_action :resolve_ctx

      def show
        # Trova il CatalogItem che ha quel content_slug dentro al suo YAML
        @item = CatalogItem.for_service("onlinecourses")
                           .where("folders_path = ? OR folders_path LIKE ?", @ctx.default_folder, "#{@ctx.default_folder}/%")
                           .find { |ci| Onlinecourses::YamlCourseLoader.load_from_catalog_item(ci)[:course][:content_slug] == params[:content_slug] }
        raise ActiveRecord::RecordNotFound unless @item

        @course_data = Onlinecourses::YamlCourseLoader.load_from_catalog_item(@item)
        @course  = @course_data[:course]
        @lessons = @course_data[:lessons]
      end

      def lesson
        show # carica @item, @course_data
        @lesson = @lessons.find { |l| l[:slug].to_s == params[:lesson_slug].to_s } or raise ActiveRecord::RecordNotFound
      end

      private
      def resolve_ctx
        @ctx = ContextResolver.new(request: request)
      end
    end
  end
end
