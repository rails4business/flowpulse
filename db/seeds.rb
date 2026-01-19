# db/seeds.rb
puts "== Bootstrap Flowpulse =="

# --- 1) Superadmin User ---
superadmin_email    = ENV.fetch("SEED_SUPERADMIN_EMAIL", "mario@mario.it")
superadmin_password = ENV.fetch("SEED_SUPERADMIN_PASSWORD", Rails.env.production? ? SecureRandom.base58(16) : "123456")

user = User.find_or_initialize_by(email_address: superadmin_email)
if user.new_record?
  user.password              = superadmin_password
  user.password_confirmation = superadmin_password
  user.superadmin            = true
  user.state_registration    = :approved
  user.save!
  puts "✅ Created superadmin: #{user.email_address}"
else
  # Assicura flag/estado anche se già esiste
  user.update!(superadmin: true, state_registration: :approved)
  puts "✅ Superadmin present: #{user.email_address}"
end

# --- 2) Lead associato allo user ---
lead = Lead.find_or_initialize_by(user: user)
lead.username ||= (user.email_address.split("@").first)
lead.name     ||= "Super"
lead.surname  ||= "Admin"
lead.email    ||= user.email_address
lead.token    ||= SecureRandom.urlsafe_base64(24)
lead.save!
puts "✅ Lead: #{lead.username} (#{lead.email})"

# --- 3) Slug category valida per Taxbranch ---
allowed_slug_categories =
  Taxbranch.validators_on(:slug_category)
           .select { |v| v.respond_to?(:in) }
           .flat_map(&:in)
           .compact

slug_category = allowed_slug_categories.first || "blog_creators"

# --- 4) Taxbranch root ---
root = Taxbranch.find_or_initialize_by(slug_label: "Root", slug_category: slug_category, ancestry: nil)
root.lead_id ||= lead.id
root.position ||= 0
root.save!
# Se il record esiste già ma con campi diversi, allineali idempotentemente
root.update!(
  lead_id:       root.lead_id || lead.id,
  slug_label:    root.slug_label.presence || "Root",
  slug_category: root.slug_category.presence || slug_category,
  ancestry:      nil
)
puts "✅ Taxbranch root: #{root.slug} (#{root.slug_category})"

# --- 5) Domini principali ---
def seed_domain(host:, title:, root:)
  Domain.find_or_create_by!(host: host) do |d|
    d.language            = I18n.default_locale.to_s
    d.title               = title
    d.description         = "Dominio principale"
    d.favicon_url         = "/favicon.ico"
    d.square_logo_url     = nil
    d.horizontal_logo_url = nil
    d.provider            = "internal"
    d.taxbranch           = root
  end
end

flowpulse = seed_domain(host: "flowpulse.net", title: "Flowpulse", root: root)
puts "✅ Domain: #{flowpulse.host} -> taxbranch_id=#{flowpulse.taxbranch_id}"

if Rails.env.development? || Rails.env.test?
  local = seed_domain(host: "localhost", title: "Flowpulse (Localhost)", root: root)
  puts "✅ Domain: #{local.host} -> taxbranch_id=#{local.taxbranch_id}"
end

puts "== Done =="

puts "== Seed: default home post =="

root ||= Taxbranch.find_by!(slug: "root")
lead = Lead.find_by!(user: User.find_by!(email_address: ENV.fetch("SEED_SUPERADMIN_EMAIL", "mario@mario.it")))

Post.find_or_create_by!(taxbranch_id: root.id) do |p|
  p.lead_id      = lead.id
  p.title        = "Benvenuto su Flowpulse"
  p.slug         = "home"
  p.description  = "Post iniziale collegato al taxbranch root."
  p.content      = "<p>Pagina iniziale di default. Modifica liberamente.</p>"
end
puts "✅ Default home post creato/già esistente"

puts "== Seed: journey map demo =="

if Rails.env.development? || Rails.env.test?
  domain_root = root.children.find_or_initialize_by(
    slug_label: "PosturaCorretta",
    slug_category: slug_category
  )
  domain_root.lead_id ||= lead.id
  domain_root.position ||= 1
  domain_root.save!
  domain_root.update!(
    lead_id:       domain_root.lead_id || lead.id,
    slug_label:    domain_root.slug_label.presence || "PosturaCorretta",
    slug_category: domain_root.slug_category.presence || slug_category,
    parent:        domain_root.parent || root
  )

  posturacorretta = seed_domain(host: "posturacorretta.org", title: "PosturaCorretta", root: domain_root)
  puts "✅ Domain: #{posturacorretta.host} -> taxbranch_id=#{posturacorretta.taxbranch_id}"

  station_specs = [
    { label: "Blog", x: 80, y: 120 },
    { label: "YouTube", x: 300, y: 120 },
    { label: "Piattaforma", x: 520, y: 120 },
    { label: "Corsi", x: 740, y: 120 },
    { label: "Accademia", x: 960, y: 120 }
  ]

  stations = station_specs.map.with_index do |spec, index|
    station = domain_root.children.find_or_initialize_by(
      slug_label: spec[:label],
      slug_category: slug_category
    )
    station.lead_id ||= lead.id
    station.position ||= index
    station.x_coordinated ||= spec[:x]
    station.y_coordinated ||= spec[:y]
    station.save!
    station
  end

  services = stations.map do |station|
    Service.find_or_initialize_by(slug: "service-#{station.slug}") do |service|
      service.lead_id       = lead.id
      service.taxbranch_id  = station.id
      service.name          = station.slug_label
      service.description   = "Servizio demo per #{station.slug_label}"
    end.tap(&:save!)
  end

  journey_specs = [
    { slug: "journey-blog-youtube", title: "Blog → YouTube", from: 0, to: 1 },
    { slug: "journey-youtube-piattaforma", title: "YouTube → Piattaforma", from: 1, to: 2 },
    { slug: "journey-piattaforma-corsi", title: "Piattaforma → Corsi", from: 2, to: 3 },
    { slug: "journey-corsi-accademia", title: "Corsi → Accademia", from: 3, to: 4 }
  ]

  journeys = journey_specs.map.with_index do |spec, index|
    Journey.find_or_create_by!(slug: spec[:slug]) do |journey|
      journey.title            = spec[:title]
      journey.lead_id          = lead.id
      journey.taxbranch_id     = stations[spec[:from]].id
      journey.end_taxbranch_id = stations[spec[:to]].id
      journey.service_id       = services[spec[:from]].id
      journey.kind             = index.zero? ? :cycle_template : :process
      journey.journey_type     = :work
      journey.phase            = :problema
    end
  end

  template_journey = journeys.first
  if template_journey
    base_time = Time.current.change(hour: 9, min: 0)
    [
      { desc: "Definizione outline contenuti", offset: 0, duration: 90, role: "Copy" },
      { desc: "Registrazione video guida", offset: 2, duration: 120, role: "Video" },
      { desc: "Montaggio e publishing", offset: 5, duration: 180, role: "Editing" }
    ].each do |step|
      Eventdate.find_or_create_by!(journey_id: template_journey.id, description: step[:desc]) do |eventdate|
        eventdate.lead_id     = lead.id
        eventdate.date_start  = base_time + step[:offset].hours
        eventdate.date_end    = base_time + step[:offset].hours + step[:duration].minutes
        eventdate.journey_role = step[:role]
        eventdate.meta        = { price_euro: 150 }
      end
    end
  end

  puts "✅ Seed journey map demo completato"
end

puts "== Seed: extra services under taxbranch 1 =="
if (parent_one = Taxbranch.find_by(id: 1))
  service_category = "service"
  extra_specs = [
    { label: "Servizio Extra A", slug_hint: "extra-a" },
    { label: "Servizio Extra B", slug_hint: "extra-b" }
  ]
  extra_specs.each_with_index do |spec, index|
    child = parent_one.children.find_or_initialize_by(
      slug_label: spec[:label],
      slug_category: service_category
    )
    child.lead_id ||= lead.id
    child.position ||= index
    child.save!

    Service.find_or_initialize_by(slug: "service-#{spec[:slug_hint]}").tap do |service|
      service.lead_id       ||= lead.id
      service.taxbranch_id  ||= child.id
      service.name          ||= spec[:label]
      service.description   ||= "Servizio demo per #{spec[:label]}"
      service.save!
    end
  end
  puts "✅ Creati 2 taxbranch + services sotto taxbranch id=1"
else
  puts "⚠️ Taxbranch id=1 non trovato: seed extra services saltato"
end
