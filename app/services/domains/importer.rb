# frozen_string_literal: true

# bin/rails domains:sync
#
# DRY_RUN=true → non scrive, mostra cosa farebbe

#  PRUNE=true → rimuove/archivia associazioni non più presenti nel file (solo brand_services)
# frozen_string_literal: true

# bin/rails domains:sync
# DRY_RUN=true bin/rails domains:sync
# PRUNE=true bin/rails domains:sync
# FILE=/percorso/custom.yml bin/rails domains:sync
# app/services/domains/importer.rb
# app/services/domains/importer.rb
module Domains
  class Importer
    def initialize(dry_run: false, prune: false, log: Rails.logger)
      @dry_run = dry_run
      @prune   = prune
      @log     = log
    end

    def sync!
      yml = YAML.safe_load_file(Rails.root.join("config/domains.yml"))

      Array(yml["services"]).each do |svc|
        ServiceDef.find_or_initialize_by(key: svc["key"]).tap do |s|
          s.assign_attributes(
            subdomain:              svc["subdomain"],
            original_domain:        svc["original_domain"],
            title:                  svc["title"],
            description:            svc["description"],
            image_url:              svc["image_url"],
            state:                  (svc["state"].presence || "develop"),
            data_source:            (svc["data_source"].presence || "yml")
          )
          @dry_run ? @log.info("[dry-run] ServiceDef #{s.key} would be saved") : s.save!
        end
      end

      Array(yml["brands"]).each do |b|
        brand = Brand.find_or_initialize_by(host: b["host"])
        brand.assign_attributes(
          controller_slug: (b["controller_slug"].presence || slug_from_host(b["host"])),
          aliases:         Array(b["aliases"]),
          description:     b["description"],
          url_landing:     b["url_landing"],
          favicon_url:     b["favicon_url"],
          pages:           Array(b["pages"]),
          show_in_home:    !!b["show_in_flowpulse_home"],
          category:        b["category_flowpulse"],
          seo:             (b["seo"] || {})
        )
        @dry_run ? @log.info("[dry-run] Brand #{brand.host} would be saved") : brand.save!
        sync_brand_services!(brand, b["active_services"])
      end
    end

    private

    def sync_brand_services!(brand, active_keys)
      want = Array(active_keys).map(&:to_s).uniq
      svc_ids = ServiceDef.where(key: want).pluck(:key, :id).to_h # {"onlinecourses"=>1, ...}
      (want - svc_ids.keys).each { |k| @log.warn "[domains:sync] unknown service key: #{k}" }

      wanted_ids = svc_ids.values
      have = brand.brand_services.pluck(:service_def_id, :id).to_h # {sid => bs_id}

      (wanted_ids - have.keys).each do |sid|
        @dry_run ? @log.info("[dry-run] Link #{brand.host} -> service_def_id=#{sid}") :
                   BrandService.create!(brand_id: brand.id, service_def_id: sid)
      end

      if @prune
        (have.keys - wanted_ids).each do |sid|
          @dry_run ? @log.info("[dry-run] Unlink #{brand.host} <- service_def_id=#{sid}") :
                     BrandService.find_by(id: have[sid])&.destroy
        end
      end
    end

    def slug_from_host(host)
      base = host.to_s.split(".").first
      s = base.gsub(/[^a-z0-9_]/i, "_")
      s =~ /\A[0-9]/ ? "#{s}1" : s
    end
  end
end
