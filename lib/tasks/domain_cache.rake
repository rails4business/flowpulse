# lib/tasks/domain_cache.rake
namespace :domain do
  desc "Precarica la cache domini"
  task warm: :environment do
    Domain.find_each { |d| DomainResolver.resolve(d.host) }
    puts "Cache domini precaricata."
  end
end
