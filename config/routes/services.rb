# Tutto è sotto il namespace controller "services/*"
scope module: "services" do
  # 1) Blocchi SPECIALIZZATI per brand specifici (prima dei generici!)
  draw "services/flowpulse"

  # 2) Routing GENERICO per qualsiasi service (ItemsController)
  #    Ordine: più specifico -> meno specifico -> catch-all
  get "/:key/i/*folder_path/:slug", to: "items#show",  as: :service_item
  get "/:key/f/*folder_path",       to: "items#index", as: :service_folder
  get "/:key",                      to: "items#index", as: :service_index

  # 3) Legacy alias (facoltativi)
  get "/catalog/:key/i/*folder_path/:slug", to: "items#show"
  get "/catalog/:key/f/*folder_path",       to: "items#index"
  get "/catalog/:key",                      to: "items#index"
end
