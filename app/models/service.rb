class Service < ApplicationRecord
  belongs_to :taxbranch, optional: true
  belongs_to :lead, optional: true

  has_many :journeys, dependent: :nullify
  has_many :eventdates, dependent: :nullify
  has_many :enrollments, dependent: :nullify
  has_many :bookings, dependent: :nullify

  store_accessor :meta, :tags, :category
end
