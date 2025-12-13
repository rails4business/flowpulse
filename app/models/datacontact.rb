class Datacontact < ApplicationRecord
  belongs_to :lead, optional: true
  belongs_to :referent_lead, class_name: "Lead", optional: true

  has_many :enrollments, dependent: :destroy
  has_many :journeys, through: :enrollments
  has_many :bookings,    dependent: :destroy
  has_many :payments,    dependent: :destroy
  has_many :mycontacts, dependent: :destroy
  has_many :certificates, dependent: :destroy

  has_many :requests_made,
           class_name: "Enrollment",
           foreign_key: :requested_by_lead_id

  has_many :invites_made,
           class_name: "Enrollment",
           foreign_key: :invited_by_lead_id

  def full_name
    [ first_name, last_name ].compact.join(" ")
  end
end
