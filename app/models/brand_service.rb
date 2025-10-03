# app/models/brand_service.rb
class BrandService < ApplicationRecord
  belongs_to :brand
  belongs_to :service_def

  validates :brand_id, :service_def_id, presence: true
  validates :service_def_id, uniqueness: { scope: :brand_id }
  # se esiste => è abilitato, quindi no flag
  scope :for_subdomain, ->(sub) { where(subdomain: sub.to_s) }
end
