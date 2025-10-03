# app/helpers/service_url_helper.rb
module ServiceUrlHelper
  # Costruisce /catalog?key=...&folder=...&slug=...
  # Resta sull’host corrente (flowpulse.<brand>).
  def service_catalog_path(key:, folder: nil, slug: nil, **opts)
    params = { key: key }
    params[:folder] = folder if folder.present?
    params[:slug]   = slug if slug.present?
    url_for(controller: "services/catalog", action: :show, only_path: true, **params.merge(opts))
  end
end
