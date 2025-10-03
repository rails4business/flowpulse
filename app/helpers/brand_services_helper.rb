# app/helpers/brand_services_helper.rb
module BrandServicesHelper
  def brand_active_services_for_current
    b = Current.brand
    return [] unless b
    b.active_services_for(Current.subdomain).order(:key)
  end
end
