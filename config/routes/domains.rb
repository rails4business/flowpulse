  # Brands
  get "/brands",     to: "domains#index", defaults: { scope: "brands" },   as: :brands
  get "/brands/:id", to: "domains#show",  defaults: { scope: "brands" },   as: :brand
  # Services
  get "/services",     to: "domains#index", defaults: { scope: "services" }, as: :services
  get "/services/:id", to: "domains#show",  defaults: { scope: "services" }, as: :service
