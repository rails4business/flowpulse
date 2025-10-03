# frozen_string_literal: true

# Piccoli helper usati da config/routes/brands.rb (e servizi)
module BrandRoutes
  module_function

  # -------- Slug sicuro per nomi di controller / path helper --------
  def controller_slug_for(brand)
    raw = brand["controller_slug"].presence || DomainRegistry.slug_from_host(brand["host"])
    safe_slug(raw)
  end

  def safe_slug(str)
    s = str.to_s.gsub(/[^a-z0-9_]/i, "_")
    s = "b_#{s}" if s =~ /\A[0-9]/ # se inizia con numero, prefissa
    s
  end

  # -------- Controller dinamico per il brand (fallback al base) ------
  def brand_controller_for(brand, action:)
    slug = controller_slug_for(brand)
    const_name = "Brands::#{slug.camelize}Controller"
    const_name.constantize.action(action)
  rescue NameError
    Brands::BrandBaseController.action(action)
  end

  # -------- Hosts utili per un brand (dominio + alias) ---------------
  def all_hosts_for_brand(brand)
    [ brand["host"], *Array(brand["aliases"]) ].compact
  end

  # -------- Constraint host per le routes del brand ------------------
  # Ritorna un hash utilizzabile in `constraints(...) do`
  def brand_constraint_for_hosts(hosts)
    regex = /\A(?:#{hosts.map { |h| Regexp.escape(h) }.join("|")})\z/
    { host: regex }
  end

  # -------- Elenco pagine extra dichiarate nel domains.yml -----------
  def brand_pages(brand)
    Array(brand["pages"]).map!(&:to_s)
  end
end
