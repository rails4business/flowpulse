# frozen_string_literal: true

# Popola config.hosts leggendo brand/alias e services (subdomain/subdomains) da config/domains.yml
# frozen_string_literal: true

require "yaml"
require "erb"

path = Rails.root.join("config/domains.yml")
data = File.exist?(path) ? YAML.safe_load(ERB.new(File.read(path)).result, aliases: true) : {}

services = Array(data["services"])
brands   = Array(data["brands"])
services_by_key = services.each_with_object({}) { |s, acc| acc[s["key"].to_s] = s }

brand_hosts = brands.flat_map { |b| [ b["host"], *Array(b["aliases"]) ] }.compact.map(&:to_s).uniq

service_hosts =
  brands.flat_map do |b|
    active_keys = Array(b["active_services"]).map(&:to_s)
    subs = active_keys.flat_map do |k|
      svc = services_by_key[k] || {}
      Array(svc["subdomains"].presence || svc["subdomain"].presence)
    end.compact.uniq
    bases = [ b["host"], *Array(b["aliases"]) ].compact
    subs.flat_map { |sub| bases.map { |h| "#{sub}.#{h}" } }
  end.uniq

allowed = (brand_hosts + service_hosts).uniq

# 👉 Imposta gli host PRIMA che il middleware venga usato
Rails.application.config.hosts.concat(allowed)

if Rails.env.development?
  Rails.application.config.hosts.concat(allowed.map { |h| "#{h}:3000" })
  # regex “elastica” per qualsiasi porta (utile con proxy/tunnel)
  Rails.application.config.hosts << /localhost(:\d+)?/
  Rails.application.config.hosts << /127\.0\.0\.1(:\d+)?/
  Rails.application.config.hosts << /\A::1\z/
end

Rails.logger.info("[allowed_hosts] #{Rails.application.config.hosts.inspect}")
