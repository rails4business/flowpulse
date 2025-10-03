module Services
  module Flowpulse
    class BlogController < ApplicationController
      before_action :resolve_ctx
      before_action -> { ensure_service!("blog") }

      def index
        @posts = Post.for_blog.for_sub(@ctx.send(:current_subdomain)).ordered
      end

      def show
        @post = Post.for_blog.for_sub(@ctx.send(:current_subdomain)).find_by!(slug: params[:slug])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      private

      def resolve_ctx
        @ctx   = ContextResolver.new(request: request)
        @brand = @ctx.brand
      end

      def ensure_service!(key)
        @ctx.service_for_key(key)
      end
    end
  end
end
