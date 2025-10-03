# frozen_string_literal: true

# app/services/catalog_items/yml_importer.rb

# RAILS_ENV=development bin/rails catalog:import
# # oppure
# RAILS_ENV=production  bin/rails catalog:import

# bin/rails runner 'puts "Totale:", CatalogItem.count'
# bin/rails runner 'pp CatalogItem.order(updated_at: :desc).limit(3).pluck(:folders_path,:service_key,:slug,:state,:published_at)'

# app/services/catalog_items/yml_importer.rb
# frozen_string_literal: true
# app/services/catalog_items/yml_importer.rb
# frozen_string_literal: true

module CatalogItems
  class YmlImporter
    ROOT_DIR = Rails.root.join("config", "data_yml")

    # Esempio valido:
    # 01_igiene-posturale_onlinecourses_2024_09_22.yml
    # 02_valutazione-articolare_teaching_v2024_10_01.yaml
    FILENAME_RE = /\A
      (?<position>\d+)_                      # 01
      (?<slug>[a-z0-9\-]+)_                  # igiene-posturale
      (?<service_key>[a-z0-9\-]+)_           # onlinecourses | teaching | questionnaire ...
      (?<rest>[^.]+)                         # 2024_09_22 | v2024_10_01 | ecc.
    \.ya?ml\z/xi

    DATE_RES = [
      /\b(?<y>\d{4})[_\-\.](?<m>\d{1,2})[_\-\.](?<d>\d{1,2})\b/, # YYYY_MM_DD
      /\b(?<y>\d{4})[_\-\.](?<d>\d{1,2})[_\-\.](?<m>\d{1,2})\b/, # YYYY_DD_MM
      /\b(?<d>\d{1,2})[_\-\.](?<m>\d{1,2})[_\-\.](?<y>\d{4})\b/  # DD_MM_YYYY
    ].freeze

    def self.call(dry_run: false, verbose: true, only_changed: false)
      new(dry_run:, verbose:, only_changed:).run
    end

    def initialize(dry_run: false, verbose: true, only_changed: false)
      @dry_run      = dry_run
      @verbose      = verbose
      @only_changed = only_changed
      @root         = ROOT_DIR
      @taxonomy     = load_taxonomy
      @now          = Time.current
    end

    def run
      raise "Missing #{ROOT_DIR}" unless @root.exist?

      files = Dir[@root.join("**", "*.yml")] + Dir[@root.join("**", "*.yaml")]
      files.sort.each { |f| import_file(Pathname.new(f)) }
      true
    end

    private

    def import_file(path)
      rel_path     = path.relative_path_from(@root).to_s
      folders_path = File.dirname(rel_path)
      yml_filename = File.basename(rel_path)

      if folders_path == "." || folders_path.blank?
        raise ArgumentError, "File YAML senza cartella: #{rel_path} (tutti i file devono stare in almeno una sottocartella di config/data_yml)"
      end

      m = yml_filename.match(FILENAME_RE)
      unless m
        log "SKIP filename non conforme: #{rel_path}"
        return
      end

      position     = m[:position].to_i
      slug         = m[:slug]
      service_key  = m[:service_key]
      version_str  = m[:rest].to_s
      published_at = extract_datetime(version_str)

      raw      = File.read(path)
      checksum = Digest::SHA256.hexdigest(raw)

      if @only_changed
        existing = CatalogItem.find_by(folders_path:, service_key:, slug:)
        if existing&.checksum == checksum
          log "UNCH #{rel_path}"
          return
        end
      end

      data    = safe_load_yaml(raw)
      title   = present(data[:title])   || present(data.dig(:meta, :title))
      summary = present(data[:summary]) || present(data[:description])

      # Tags dai file + dai segmenti del path (per filtri/ricerca)
      tags = Array(data[:tags]).map(&:to_s)
      tags |= folders_path.split("/") if folders_path.present?

      # Dominî dalla taxonomy (match esatto o prefisso più lungo)
      domains = domains_for(folders_path)
      data[:domains] = domains if domains.present?

      # Stato (pubblica se flagged o se la data nel filename è nel passato)
      state = if truthy?(data[:published]) || (published_at && published_at <= @now)
                "published"
      else
                "draft"
      end

      # TSV (full-text)
      tsv_text = build_tsv_text(title:, summary:, tags:, data:)

      attrs = {
        # Provenienza
        folders_path: folders_path,
        source_path:  rel_path,
        yml_filename: yml_filename,

        # Identità logica
        service_key:  service_key,
        slug:         slug,
        position:     position,
        version:      present(data[:version]) || version_str,

        # Visibilità
        domains:      domains,
        # subdomain:  (se vuoi dedurlo dalla taxonomy, valorizzalo qui)

        # Metadati editoriali
        title:        title,
        summary:      summary,
        tags:         tags,

        # Stato
        state:        state,
        published_at: published_at,

        # Integrità e ricerca
        checksum:     checksum,
        data:         data,
        tsv:          Arel.sql("to_tsvector('simple', #{ActiveRecord::Base.connection.quote(tsv_text)})")
      }

      # folder = ultimo segmento di folders_path
      attrs[:folder] = folders_path.split("/").last

      upsert!(attrs)
      log "OK  #{state.ljust(9)}  #{folders_path}/#{yml_filename}"
    rescue => e
      log "ERR #{rel_path} -> #{e.class}: #{e.message}"
      raise if @verbose && !@dry_run
    end

    def upsert!(attrs)
      return if @dry_run

      # 1) preferisci il filename, che ora è unico globale
      rec = CatalogItem.find_by(yml_filename: attrs[:yml_filename])

      # 2) fallback su chiave logica preesistente (utile se stai migrando un db vecchio)
      rec ||= CatalogItem.find_by(
        folders_path: attrs[:folders_path],
        service_key:  attrs[:service_key],
        slug:         attrs[:slug]
      )

      rec ||= CatalogItem.new

      rec.assign_attributes(attrs)

      unless rec.save
        warn <<~ERR
          VALIDATION ERROR for #{attrs[:source_path]}
            yml_filename: #{attrs[:yml_filename].inspect}
            folders_path: #{attrs[:folders_path].inspect}
            service_key:  #{attrs[:service_key].inspect}
            slug:         #{attrs[:slug].inspect}
            errors:       #{rec.errors.full_messages.join("; ")}
        ERR
        raise ActiveRecord::RecordInvalid, rec
      end
    end

    def extract_datetime(str)
      DATE_RES.each do |re|
        if (m = str.match(re))
          y   = m[:y].to_i
          mon = m[:m].to_i
          d   = m[:d].to_i
          # swap se mese > 12 ma giorno <= 12
          if mon > 12 && d <= 12
            mon, d = d, mon
          end
          return Time.zone.local(y, mon, d)
        end
      end
      nil
    end

    def load_taxonomy
      file = Rails.root.join("config", "taxonomy.yml")
      return {} unless file.exist?
      YAML.safe_load(File.read(file), permitted_classes: [], aliases: false) || {}
    rescue
      {}
    end

    def domains_for(folders_path)
      return [] if @taxonomy.blank?

      exact = @taxonomy[folders_path] || @taxonomy[folders_path.to_s]
      return Array(exact) if exact.present?

      key = @taxonomy.keys
                     .map(&:to_s)
                     .select { |k| folders_path.start_with?(k) }
                     .max_by(&:length)
      Array(@taxonomy[key])
    end

    def build_tsv_text(title:, summary:, tags:, data:)
      chunks = []
      chunks << title if title
      chunks << summary if summary
      chunks << tags.join(" ") if tags.present?
      chunks.concat strings_from_data(data, %w[keywords seo body content notes subtitle heading])
      chunks.compact.join(" ")
    end

    def strings_from_data(h, keys)
      keys.flat_map do |k|
        v = h[k] || h[k.to_sym]
        case v
        when String then v
        when Array  then v.grep(String)
        when Hash   then v.values.grep(String)
        else nil
        end
      end
    end

    def safe_load_yaml(raw)
      y = YAML.safe_load(raw, permitted_classes: [], aliases: false)
      y = {} unless y.is_a?(Hash)
      y.with_indifferent_access
    rescue Psych::Exception
      { raw: raw }.with_indifferent_access
    end

    def present(val) = val.presence

    def truthy?(val)
      val == true || val.to_s.strip.downcase.in?(%w[true yes 1 si sì])
    end

    def log(msg)
      puts msg if @verbose
    end
  end
end
