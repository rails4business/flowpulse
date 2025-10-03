# config/routes/superadmin.rb  (NO Rails.application.routes.draw qui!)

# --- Area /superadmin (sempre montata, accesso filtrato da controller) ---
namespace :superadmin do
  # Dashboard + azioni operative sul catalog
  get  "catalog",         to: "catalog#dashboard",      as: :catalog
  post "catalog/import",  to: "catalog#import",         as: :catalog_import
  post "catalog/changed", to: "catalog#import_changed", as: :catalog_import_changed
  post "catalog/rebuild", to: "catalog#rebuild",        as: :catalog_rebuild

  # CRUD opzionali
  resources :brands
  resources :services
end

# --- Area su SOTTOdomini (ex Services::Hub) ---
SubdomainRequired = ->(req) { req.subdomains.present? && !req.subdomains.include?("www") }

constraints(SubdomainRequired) do
  # root hub solo su subdomain (es. flowpulse.posturacorretta.org/)
  root "superadmin/hub#index", as: :services_hub_root

  # macro-catalog su subdomain
  get "/catalog", to: "superadmin/catalog#show", as: :service_catalog

  # strumenti su catalog_items solo su subdomain (e filtrati a superadmin dal controller)
  namespace :superadmin do
    resources :catalog_items, only: [ :index, :show ], param: :slug
  end
end
