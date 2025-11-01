# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

puts "== Seeding superadmin user and lead =="

superadmin_email = "mario@mario.it"
superadmin_username = "mario"

# 1️⃣ Crea (o trova) lo user superadmin
user = User.find_or_initialize_by(email_address: superadmin_email)
user.password = "123456"
user.password_confirmation = "123456"
user.superadmin = true
user.state_registration = :approved
user.save!

puts "✅ User superadmin: #{user.email_address} (id=#{user.id})"

# 2️⃣ Crea (o trova) il lead associato
lead = Lead.find_or_initialize_by(user: user)
lead.username ||= superadmin_username
lead.name ||= "Super"
lead.surname ||= "Admin"
lead.email ||= user.email_address
lead.token ||= SecureRandom.urlsafe_base64(24)
lead.save!

puts "✅ Lead superadmin: #{lead.username} (token=#{lead.token})"

puts "== Done =="
