class User < ApplicationRecord
  has_secure_password
   before_validation do
    if respond_to?(:email_address) && email_address.present?
      self.email_address = email_address.strip.downcase
    elsif respond_to?(:email) && email.present?
      self.email = email.strip.downcase
    end
  end
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
