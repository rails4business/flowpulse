# app/services/domain_resolver.rb
class DomainResolver
  TTL = 10.minutes

  class << self
    def resolve(host)
      key = "domain:#{normalize(host)}"
      Rails.cache.fetch(key, expires_in: TTL) do
        Domain.includes(:taxbranch).find_by(host: normalize(host))
      end
    end

    def normalize(host)
      host.to_s.downcase.sub(/\Ahttps?:\/\//, "").sub(/\Awww\./, "").split(":").first
    end
  end
end
