class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_one :lead, inverse_of: :user, dependent: :nullify

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  enum :state_registration, { pending: 0, approved: 1 }, default: :pending

  # app/models/user.rb
  def approved?
    state_registration == "approved"
  end
  # Accesso rapido
  delegate :name, :surname, :username, :email, to: :lead, prefix: true, allow_nil: true
end
