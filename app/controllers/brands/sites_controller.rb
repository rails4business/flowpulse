# app/controllers/brands/sites_controller.rb
module Brands
  class SitesController < BrandBaseController
    allow_unauthenticated_access only: %i[home about contact privacy terms page]
  end
end
