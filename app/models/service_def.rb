# app/models/service_def.rb
class ServiceDef < ApplicationRecord
  has_many :brand_services, dependent: :destroy
  has_many :brands, through: :brand_services
  validates :key, :subdomain, :data_source, presence: true


  # decidi tu la semantica "attivo":
  # - se usi 'active' come stato buono
  scope :active, -> { where.not(state: %w[archived disabled]) } # adatta ai tuoi stati
  def display_name = title.presence || key.humanize # in alternativa, più permissivo:
  # scope :active, -> { where.not(state: %w[archived disabled]) }
end
