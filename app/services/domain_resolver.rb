# app/services/domain_resolver.rb
class DomainResolver
  TTL = 10.minutes

  class << self
    def resolve(host)
      normalized = normalize(host)
      return nil if normalized.blank?

      key = "domain:#{normalized}"

      Rails.cache.fetch(key, expires_in: TTL) do
        find_domain(normalized)
      end
    end

    private

    # Gestione host e fallback
    def find_domain(host)
      # 1. Ricerca esatta (senza www.)
      dom = Domain.includes(:taxbranch).find_by(host: host)

      # 2. Fallback su 'www.' se non trovato
      dom ||= Domain.includes(:taxbranch).find_by(host: "www.#{host}")

      # 3. Fallback su dominio base (per sottodomini tipo academy.flowpulse.net)
      dom ||= Domain.includes(:taxbranch).find_by(host: root_domain(host))

      dom
    end

    def normalize(host)
      host.to_s
          .strip
          .downcase
          .sub(/\Ahttps?:\/\//, "")
          .sub(/\Awww\./, "")
          .split(":").first
    end

    # Rimuove il primo sottodominio: "academy.flowpulse.net" -> "flowpulse.net"
    def root_domain(host)
      parts = host.split(".")
      parts.shift if parts.size > 2
      parts.join(".")
    end
  end
end
