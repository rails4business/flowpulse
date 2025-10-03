# lib/tasks/catalog.rake
# bin/rails catalog:index_yml     # lista i file sotto config/data_yml
# bin/rails catalog:import        # importa tutto
# bin/rails catalog:import:dry    # fa la simulazione (non salva)
# bin/rails catalog:changed       # importa solo i file con checksum diverso
# bin/rails catalog:rebuild       # svuota la tabella e ricarica tutto
# bin/rails catalog:report
# bin/rails runner 'pp CatalogItem.where(state: "published").limit(5).pluck(:folders_path,:service_key,:slug,:published_at)'

namespace :catalog do
  desc "Lista i file YAML sotto config/data_yml (non richiede boot Rails)"
  task :index_yml do
    app_root  = File.expand_path("../../", __dir__)
    data_root = File.join(app_root, "config", "data_yml")
    files = Dir[File.join(data_root, "**", "*.{yml,yaml}")].sort
    if files.empty?
      puts "Nessun file .yml trovato sotto #{data_root}"
    else
      files.each { |f| puts Pathname.new(f).relative_path_from(Pathname.new(app_root)) }
      puts "\nTotale: #{files.size}"
    end
  end

  desc "Importa i catalog items (richiede ambiente Rails)"
  task import: :environment do
    CatalogItems::YmlImporter.call(dry_run: false, verbose: true)
  end

  desc "Dry-run import (nessun salvataggio)"
  task "import:dry" => :environment do
    CatalogItems::YmlImporter.call(dry_run: true, verbose: true)
  end

  desc "Importa solo i .yml modificati (checksum)"
  task changed: :environment do
    CatalogItems::YmlImporter.call(dry_run: false, verbose: true, only_changed: true)
  end

  desc "Ricostruisce catalog_items (svuota + import) in modo adapter-safe"
  task rebuild: :environment do
    conn = ActiveRecord::Base.connection
    adapter = conn.adapter_name.to_s

    if adapter =~ /postgre/i
      conn.execute("TRUNCATE catalog_items RESTART IDENTITY CASCADE")
    else
      CatalogItem.delete_all
      if conn.respond_to?(:reset_pk_sequence!)
        conn.reset_pk_sequence!("catalog_items")
      end
    end

    CatalogItems::YmlImporter.call(dry_run: false, verbose: true)
  end

  desc "Report rapido: totali, per state e per service_key, top cartelle"
  task report: :environment do
    puts "== Catalog Items =="
    puts "Totale: #{CatalogItem.count}"

    puts "\n-- Per state --"
    CatalogItem.group(:state).order("count_all DESC").count.each do |state, n|
      puts "#{state.ljust(10)} #{n}"
    end

    puts "\n-- Per service_key --"
    CatalogItem.group(:service_key).order("count_all DESC").count.each do |svc, n|
      puts "#{svc.ljust(18)} #{n}"
    end

    puts "\n-- Top 10 folders_path --"
    CatalogItem.group(:folders_path).order("count_all DESC").limit(10).count.each do |fp, n|
      puts "#{fp}  -> #{n}"
    end

    puts "\n-- Pubblicati oggi (debug) --"
    today = Time.zone.today
    n_today = CatalogItem.where(published_at: today.all_day).count
    puts "published_at = oggi: #{n_today}"
  end
end
