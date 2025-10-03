# lib/tasks/catalog_lint.rake
# bin/rails catalog:status
# bin/rails catalog:lint

namespace :catalog do
  desc "Panoramica rapida tra filesystem e DB"
  task status: :environment do
    root = Rails.root.join("config", "data_yml")
    files = Dir[root.join("**", "*.{yml,yaml}")].sort
    puts "== Catalog Status =="
    puts "Filesystem (YML): #{files.size}"
    puts "DB records       : #{CatalogItem.count}"

    puts "\n-- Per state --"
    pp CatalogItem.group(:state).order("count_all DESC").count

    puts "\n-- Per service_key --"
    pp CatalogItem.group(:service_key).order("count_all DESC").count

    puts "\n-- Ultimi 5 import --"
    CatalogItem.order(updated_at: :desc).limit(5).pluck(:yml_filename, :state, :updated_at).each do |row|
      puts "  #{row[0]} | #{row[1]} | #{row[2]}"
    end
  end

  desc "Lint approfondito: filename non conformi, mancanti in DB, orfani, duplicati, checksum, slug_key"
  task lint: :environment do
    root = Rails.root.join("config", "data_yml")
    unless root.exist?
      abort "Manca la cartella #{root}"
    end

    filename_re = CatalogItems::YmlImporter::FILENAME_RE

    fs_files = Dir[root.join("**", "*.{yml,yaml}")].sort.map { |f| Pathname(f).relative_path_from(root).to_s }
    fs_by_filename = Hash.new { |h, k| h[k] = [] }
    fs_files.each do |rel|
      fs_by_filename[File.basename(rel)] << rel
    end

    db_all = CatalogItem.select(:id, :yml_filename, :source_path, :folders_path, :service_key, :slug, :checksum, :state, :updated_at).to_a
    db_by_filename = db_all.group_by(&:yml_filename)

    puts "== Lint =="
    puts "FS files: #{fs_files.size}"
    puts "DB recs : #{db_all.size}"

    # 1) Filename non conformi
    bad = fs_files.reject { |rel| File.basename(rel).match?(filename_re) }
    if bad.any?
      puts "\n[ERR] Filename NON conformi (#{bad.size}):"
      bad.each { |rel| puts "  - #{rel}" }
    else
      puts "\n[OK] Tutti i filename rispettano la regex."
    end

    # 2) Duplicati di filename nel FS (collidono con indice unico su yml_filename)
    dup_fs = fs_by_filename.select { |_, arr| arr.size > 1 }
    if dup_fs.any?
      puts "\n[ERR] Duplicati di yml_filename nel FILESYSTEM:"
      dup_fs.each { |fn, arr| puts "  - #{fn} -> #{arr.join(', ')}" }
    else
      puts "\n[OK] Nessun duplicato di yml_filename nel filesystem."
    end

    # 3) File presenti nel FS ma assenti nel DB
    missing_in_db = fs_by_filename.keys.reject { |fn| db_by_filename.key?(fn) }
    if missing_in_db.any?
      puts "\n[WARN] File presenti nel FS ma NON in DB (#{missing_in_db.size}):"
      missing_in_db.each { |fn| puts "  - #{fn}  (#{fs_by_filename[fn].first})" }
    else
      puts "\n[OK] Tutti i file del FS hanno un record in DB (per yml_filename)."
    end

    # 4) Record in DB senza file (orfani)
    fs_filenames_set = fs_by_filename.keys.to_set
    orphans = db_all.reject { |rec| fs_filenames_set.include?(rec.yml_filename) }
    if orphans.any?
      puts "\n[WARN] Record ORFANI in DB (file mancante su FS) (#{orphans.size}):"
      orphans.each do |rec|
        puts "  - #{rec.yml_filename}  (folders_path: #{rec.folders_path}, source_path: #{rec.source_path})"
      end
    else
      puts "\n[OK] Nessun record orfano in DB."
    end

    # 5) Duplicati slug_key nel DB (stessa service_key+slug)
    dup_slug_key = CatalogItem.group(:service_key, :slug).having("COUNT(*) > 1").count
    if dup_slug_key.any?
      puts "\n[ERR] Duplicati di slug_key (service_key+slug) nel DB:"
      dup_slug_key.each do |(svc, slg), n|
        rows = CatalogItem.where(service_key: svc, slug: slg).order(updated_at: :desc).pluck(:yml_filename, :state, :updated_at)
        puts "  - #{svc}/#{slg} -> #{n} record:"
        rows.each { |r| puts "      * #{r[0]} | #{r[1]} | #{r[2]}" }
      end
    else
      puts "\n[OK] Nessun duplicato di slug_key nel DB."
    end

    # 6) Checksum: divergenze FS vs DB
    require "digest"
    changed = []
    fs_files.each do |rel|
      abs = root.join(rel)
      raw = File.read(abs)
      checksum = Digest::SHA256.hexdigest(raw)
      fn = File.basename(rel)
      if (recs = db_by_filename[fn])
        recs.each do |rec|
          changed << [ fn, rec.checksum, checksum ] if rec.checksum != checksum
        end
      end
    end
    if changed.any?
      puts "\n[INFO] File con CHECKSUM differente tra FS e DB (#{changed.size}):"
      changed.each { |fn, old, newc| puts "  - #{fn}  (db: #{old&.first(8)}..., fs: #{newc.first(8)}...)" }
    else
      puts "\n[OK] Nessuna differenza di checksum (DB in linea col FS)."
    end

    # 7) Conflitti potenziali: due file diversi con stesso slug_key
    # (utile quando l'indice unico su slug_key non c'è, o prima di abilitarlo)
    parsed = fs_files.map do |rel|
      m = File.basename(rel).match(filename_re)
      next nil unless m
      {
        filename: File.basename(rel),
        service_key: m[:service_key],
        slug: m[:slug],
        rel: rel
      }
    end.compact

    fs_dup_slugkey = parsed.group_by { |h| [ h[:service_key], h[:slug] ] }.select { |_, arr| arr.size > 1 }
    if fs_dup_slugkey.any?
      puts "\n[ERR] Nel FILESYSTEM esistono piu' file con lo stesso slug_key:"
      fs_dup_slugkey.each do |(svc, slg), arr|
        puts "  - #{svc}/#{slg}:"
        arr.each { |h| puts "      * #{h[:filename]} (#{h[:rel]})" }
      end
    else
      puts "\n[OK] Nessuna collisione di slug_key nel filesystem."
    end

    puts "\n== Fine lint =="
  end
end
