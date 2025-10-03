# lib/tasks/domains.rake
# # frozen_string_literal: true

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
# app/services/domains/importer.rbs
namespace :domains do
  desc "Importa e sincronizza brands + services da config/domains.yml"
  task sync: :environment do
    dry   = ENV["DRY_RUN"].present?
    prune = ENV["PRUNE"].present?

    Domains::Importer.new(dry_run: dry, prune: prune).sync!
    puts "✅ Domains sync completato"
  end
end
