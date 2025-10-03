# lib/tasks/domains_validate.rake

namespace :domains do
  desc "Validate config/domains.yml and service YML folders"
  task validate: :environment do
    DomainRegistry.load!
    errors = []

    # services keys unici
    if DomainRegistry.services.keys.size != DomainRegistry.raw["services"].size
      errors << "Duplicate service keys detected."
    end

    # brand host/alias collision
    all_hosts = DomainRegistry.brands.values.flat_map { |b| DomainRegistry.all_hosts_for_brand(b) }
    if all_hosts.size != all_hosts.uniq.size
      errors << "Duplicate hosts/aliases across brands."
    end

    # yml_root_service existence
    root = DomainRegistry.yml_root_service
    errors << "Missing yml_root_service path: #{root}" unless Dir.exist?(root)

    if errors.any?
      puts "❌ Validation errors:"
      errors.each { |e| puts " - #{e}" }
      exit(1)
    else
      puts "✅ domains.yml looks good."
    end
  end
end
