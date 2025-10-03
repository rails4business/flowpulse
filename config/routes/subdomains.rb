# config/routes/subdomains.rb
Brand.includes(brand_services: :service_def).find_each do |brand|
  # root dominio nudo
  constraints host: /\A#{Regexp.escape(brand.host)}\z/ do
    root to: "brands/home#show", as: "brand_root_#{brand.host.tr('.', '_')}"
  end

  # subdomain attivi = quelli dei service_defs associati al brand
  subdomains = brand.brand_services.joins(:service_def)
                     .pluck("service_defs.subdomain")
                     .uniq
                     .reject(&:blank?)

  subdomains.each do |sub|
    host = "#{sub}.#{brand.host}"
    constraints host: /\A#{Regexp.escape(host)}\z/ do
      root to: "services/hub#show", as: "root_#{host.tr('.', '_')}"
    end
  end
end
