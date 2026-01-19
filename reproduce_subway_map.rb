
# reproduce_subway_map.rb
begin
  ActiveRecord::Base.transaction do
    lead = Lead.first || Lead.create!(email: 'test@example.com', token: 'test', username: 'test')

    # Create 3 Taxbranches (Stations)
    t1 = Taxbranch.create!(slug_category: 'test', slug_label: 'Station A', lead: lead)
    t2 = Taxbranch.create!(slug_category: 'test', slug_label: 'Station B', lead: lead)
    t3 = Taxbranch.create!(slug_category: 'test', slug_label: 'Station C', lead: lead)

    # Create 3 Services attached to these Taxbranches
    s1 = Service.create!(name: 'Service A', taxbranch: t1, slug: 'service-a', lead: lead)
    s2 = Service.create!(name: 'Service B', taxbranch: t2, slug: 'service-b', lead: lead)
    s3 = Service.create!(name: 'Service C', taxbranch: t3, slug: 'service-c', lead: lead)

    # Create Journeys (Tracks)
    # A -> B
    Journey.create!(title: 'J1', taxbranch: t1, end_taxbranch: t2, lead: lead)
    # B -> C
    Journey.create!(title: 'J2', taxbranch: t2, end_taxbranch: t3, lead: lead)

    # Reload
    s1.reload
    s2.reload
    s3.reload

    puts "--- Verification Results ---"
    puts "Service A next services: #{s1.next_services.pluck(:name)}"
    puts "Service B next services: #{s2.next_services.pluck(:name)}"
    puts "Service B previous services: #{s2.previous_services.pluck(:name)}"
    puts "Service C previous services: #{s3.previous_services.pluck(:name)}"

    # Check if correct
    raise "Fail: Service A should connect to Service B" unless s1.next_services.include?(s2)
    raise "Fail: Service B should connect to Service C" unless s2.next_services.include?(s3)
    raise "Fail: Service B should come from Service A" unless s2.previous_services.include?(s1)
    raise "Fail: Service C should come from Service B" unless s3.previous_services.include?(s2)

    puts "SUCCESS: Associations are working as expected!"
    
    raise ActiveRecord::Rollback # clean up
  end
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace
end
