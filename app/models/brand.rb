# app/models/brand.rb
class Brand < ApplicationRecord
  has_many :brand_services, dependent: :destroy
  has_many :service_defs, through: :brand_services



  # se vuoi cercare per param :id leggibile
  def to_param = controller_slug



  # normalizza host: downcase, rimuove protocollo/porta, toglie 'www.' iniziale
  def self.normalize_host(host)
    h = host.to_s.downcase
    h = h.sub(/\Ahttps?:\/\//, "")
    h = h.split(":").first.to_s
    h.sub(/\Awww\./, "")
  end

  # True se h è esattamente host/alias o un *sottodominio* di quello
  def matches_host?(h)
    candidates = [ host, *Array(aliases) ].compact.map(&:downcase)
    candidates.any? { |base| h == base || h.end_with?(".#{base}") }
  end

  # Trova il brand per host/alias o qualunque sottodominio
  def self.for_host(request_host)
    h = normalize_host(request_host)
    return nil if h.blank?

    # 1) match veloce: esatto su host o alias
    exact = where("host = :h OR aliases @> :arr", h:, arr: [ h ].to_json).first
    return exact if exact

    # 2) fallback: sottodomini (es. *.posturacorretta.org)
    # (pochi brand ⇒ ok in Ruby; se diventano tanti, si può ottimizzare)
    all.find { |b| b.matches_host?(h) }
  end
  def self.normalize_host(host)
    host.to_s.downcase.sub(/\Ahttps?:\/\//, "").split(":").first.to_s.sub(/\Awww\./, "")
  end

  def matches_host?(h)
    cand = [ host, *Array(aliases) ].compact.map(&:downcase)
    cand.any? { |base| h == base || h.end_with?(".#{base}") }
  end

  def self.for_host(request_host)
    h = normalize_host(request_host)
    return nil if h.blank?
    exact = where("host = :h OR aliases @> :arr", h:, arr: [ h ].to_json).first
    return exact if exact
    all.find { |b| b.matches_host?(h) }
  end
   def to_param
    controller_slug.presence || host.to_s.parameterize
  end
  def display_name
    seo&.fetch("title", nil).presence || controller_slug.to_s.titleize.presence || host
  end
  # tutti i servizi attivi del brand (indipendente dal sub)
  def active_services_all
    service_defs.active
  end

   # servizi attivi del brand per uno specifico subdomain

   def active_services_for(subdomain)
    service_defs.where.not(state: %w[archived disabled]).where(subdomain: subdomain.to_s)
  end
end
