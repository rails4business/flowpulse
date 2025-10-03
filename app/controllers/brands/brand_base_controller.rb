# app/controllers/brands/brand_base_controller.rb
module Brands
  class BrandBaseController < ApplicationController
   allow_unauthenticated_access only: %i[home about contact privacy terms page]
    before_action :assign_brand
    before_action :load_brand_services
    layout "brands"

    class_attribute :default_brand_slug, default: "posturacorretta"

    def home    = render_brand_page("home")
    def about   = render_brand_page("about")
    def contact = render_brand_page("contact")
    def privacy = render_brand_page("privacy")
    def terms   = render_brand_page("terms")
    def page
      page = params[:page].to_s
      allowed = %w[home about contact privacy terms] # aggiungi custom se vuoi
      raise ActionController::RoutingError, "Not Found" unless allowed.include?(page)
      render_brand_page(page)
    end

    private
    def assign_brand
      @brand = Current.brand || Brand.for_host(request.host) || Brand.find_by(controller_slug: self.class.default_brand_slug)
      raise ActionController::RoutingError, "Brand not found" unless @brand
      @brand_slug = @brand.controller_slug.presence || self.class.default_brand_slug
    end

    def load_brand_services
        @brand_services = @brand.active_services_all.order(:key)
    end

    def render_brand_page(page)
      tpl_specific = "brands/#{@brand_slug}/#{page}"
      tpl_fallback = "brands/brand_generic/#{page}"
      render template: (lookup_context.exists?(tpl_specific) ? tpl_specific : tpl_fallback)
    end
  end
end
