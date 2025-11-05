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
root = Taxbranch.find_or_create_by!(slug: "root") do |t|
  t.lead_id       = lead.id
  t.slug_label    = "Root"
  t.slug_category = slug_category
  t.description   = "Nodo principale del sito"
  t.position      = 0
end
# Se il record esiste già ma con campi diversi, allineali idempotentemente
root.update!(
  lead_id:       root.lead_id || lead.id,
  slug_label:    root.slug_label.presence || "Root",
  slug_category: root.slug_category.presence || slug_category
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

root = Taxbranch.find_by!(slug: "root")
lead = Lead.find_by!(user: User.find_by!(email_address: ENV.fetch("SEED_SUPERADMIN_EMAIL", "mario@mario.it")))

Post.find_or_create_by!(taxbranch_id: root.id) do |p|
  p.lead_id      = lead.id
  p.title        = "Benvenuto su Flowpulse"
  p.slug         = "home"
  p.description  = "Post iniziale collegato al taxbranch root."
  p.content      = "<p>Pagina iniziale di default. Modifica liberamente.</p>"
  p.published_at = Time.current
  p.status       = "published" rescue nil
end
puts "✅ Default home post creato/già esistente"
