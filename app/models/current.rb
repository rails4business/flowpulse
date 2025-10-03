# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :brand, :subdomain, :base_host

  # attribute :session
  # delegate :user, to: :session, allow_nil: true
end
