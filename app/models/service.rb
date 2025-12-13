require "securerandom"

class Service < ApplicationRecord
  belongs_to :taxbranch, optional: true
  belongs_to :lead, optional: true

  has_many :journeys, dependent: :nullify
  has_many :eventdates, dependent: :nullify
  has_many :enrollments, dependent: :nullify
  has_many :bookings, dependent: :nullify
  has_many :certificates, dependent: :restrict_with_exception

  store_accessor :meta, :tags, :category

  validates :slug, presence: true, uniqueness: true

  before_validation :ensure_slug!

  def allowed_roles=(value)
    self[:allowed_roles] = normalize_role_list(value)
  end

  def output_roles=(value)
    self[:output_roles] = normalize_role_list(value)
  end

  def allowed_roles_text
    Array(allowed_roles).join("\n")
  end

  def output_roles_text
    Array(output_roles).join("\n")
  end

  def verifier_roles=(value)
    self[:verifier_roles] = normalize_role_list(value)
  end

  def verifier_roles_text
    Array(verifier_roles).join("\n")
  end

  private

  def ensure_slug!
    return if slug.present?

    base = (name.presence || "service-#{SecureRandom.hex(3)}").parameterize
    self.slug = base.presence || "service-#{SecureRandom.hex(3)}"
  end

  def normalize_role_list(value)
    list =
      case value
      when String
        value.split(/[\n,;]/)
      when Array
        value
      else
        Array(value)
      end

    list.filter_map { |entry| entry.to_s.strip.presence }.uniq
  end
end
