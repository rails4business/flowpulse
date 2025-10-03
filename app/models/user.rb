# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Alias comodo per leggere/scrivere come "user.email" in Ruby,
  # ma ATTENZIONE: per le query usa sempre email_address (colonna reale).
  alias_attribute :email, :email_address

  # Normalizzazione email (usa la nuova API se c’è, fallback se non c’è)
  if respond_to?(:normalizes)
    normalizes :email_address, with: ->(e) { e.to_s.strip.downcase.presence }
  else
    before_validation { self.email_address = email_address.to_s.strip.downcase.presence }
  end

  # Validazioni
  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "non è valida" }

  validates :password, length: { minimum: 6 }, allow_nil: true
end
