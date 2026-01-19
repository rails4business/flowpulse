
# reproduce_service_rails.rb
begin
  ActiveRecord::Base.transaction do
    puts "Creating test data for Service Rails..."
    lead = Lead.first || Lead.create!(email: 'test_rails@example.com', token: 'test_rails', username: 'test_rails')

    # Create Stations
    # T1: Service
    # T2: Service
    # T3: No Service (Generic)
    t1 = Taxbranch.create!(slug_category: 'test', slug_label: 'Station 1', lead: lead)
    t2 = Taxbranch.create!(slug_category: 'test', slug_label: 'Station 2', lead: lead)
    t3 = Taxbranch.create!(slug_category: 'test', slug_label: 'Generic Node', lead: lead)

    # Attach Services
    Service.create!(name: 'S1', taxbranch: t1, slug: 's-1', lead: lead)
    Service.create!(name: 'S2', taxbranch: t2, slug: 's-2', lead: lead)

    # Create Journeys
    # J1: S1 -> S2 (Service Rail)
    j1 = Journey.create!(title: 'J-Service-to-Service', taxbranch: t1, end_taxbranch: t2, lead: lead)
    
    # J2: S1 -> T3 (Service -> Generic)
    j2 = Journey.create!(title: 'J-Service-to-Generic', taxbranch: t1, end_taxbranch: t3, lead: lead)

    # J3: T3 -> S2 (Generic -> Service)
    j3 = Journey.create!(title: 'J-Generic-to-Service', taxbranch: t3, end_taxbranch: t2, lead: lead)

    puts "--- Checking Scopes ---"
    
    # Check Service Rails
    rails = Journey.service_rails
    puts "Service Rails count: #{rails.count}"
    raise "Fail: J1 should be a service rail" unless rails.include?(j1)
    raise "Fail: J2 should NOT be a service rail" if rails.include?(j2)
    raise "Fail: J3 should NOT be a service rail" if rails.include?(j3)

    # Check Connecting Rails
    connecting = Journey.connecting_rails
    puts "Connecting Rails count: #{connecting.count}"
    raise "Fail: J1 should NOT be a connecting rail" if connecting.include?(j1)
    raise "Fail: J2 should be a connecting rail" unless connecting.include?(j2)
    raise "Fail: J3 should be a connecting rail" unless connecting.include?(j3)

    # Check Taxbranch scopes
    stations = Taxbranch.service_stations
    puts "Service Stations count: #{stations.count}"
    raise "Fail: T1 should be a station" unless stations.include?(t1)
    raise "Fail: T2 should be a station" unless stations.include?(t2)
    raise "Fail: T3 should NOT be a station" if stations.include?(t3)

    puts "SUCCESS: Service Rails logic verified!"
    
    raise ActiveRecord::Rollback
  end
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace
end
