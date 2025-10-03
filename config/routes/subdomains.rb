# config/routes/subdomains.rb
begin
  # Evita di toccare il DB se non è pronto
  if ActiveRecord::Base.connection_pool.connected? &&
     Brand.table_exists? &&
     BrandService.table_exists? &&
     ServiceDef.table_exists?

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
  else
    Rails.logger.warn "[ROUTES] Skip dynamic brand routes (tables missing)"
  end
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
  Rails.logger.warn "[ROUTES] Skip dynamic brand routes: #{e.class} #{e.message}"
end
