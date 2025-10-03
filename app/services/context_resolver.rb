# app/services/context_resolver.rb
class ContextResolver
  def initialize(request:)
    @request = request
  end

  def brand
    @brand ||= Brand.find_by!(host: brand_host)
  end

  def active_services_for_subdomain
    brand.brand_services
         .joins(:service_def)
         .where(service_defs: { subdomain: current_subdomain })
         .includes(:service_def)
         .map(&:service_def)
  end

  def service_for_key(key)
    brand.brand_services
         .joins(:service_def)
         .find_by!(service_defs: { key: key, subdomain: current_subdomain })
         .service_def
  end

  def data_source_for(key)
    service_for_key(key).data_source # "db" | "yml"
  end

  # Brand NON ha la colonna default_folder nello schema: usiamo seo["default_folder"] o un guess
  def default_folder
    from_seo = brand.seo.is_a?(Hash) ? brand.seo["default_folder"].to_s.presence : nil
    return from_seo if from_seo

    guess = guess_default_folder_for_subdomain
    guess || "" # sempre una stringa
  end

  private

  def current_subdomain
    (@request.subdomain || "").to_s
  end

  # NIENTE request.tld: ActionDispatch::Request non lo espone
  def brand_host
    # con config.action_dispatch.tld_length = 2, su flowpulse.posturacorretta.org → "posturacorretta.org"
    @request.domain.presence || @request.host
  end

  # euristica: cartella più frequente per questo subdomain tra i catalog_items
  def guess_default_folder_for_subdomain
    row = CatalogItem.where(subdomain: current_subdomain)
                     .group(:folders_path)
                     .order(Arel.sql("COUNT(*) DESC"))
                     .limit(1)
                     .count
                     .first
    row&.first # => "01_salute/01_posturacorretta/..." oppure nil
  end
end
