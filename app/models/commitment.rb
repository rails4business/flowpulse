class Commitment < ApplicationRecord
  belongs_to :taxbranch, optional: true
  belongs_to :eventdate

  has_many :bookings


  enum :commitment_kind, {
    internal_task: 0,
    operator_role: 1,
    client_commitment: 2,
    event_session: 3
  }

  validates :eventdate, presence: true

  delegate :journey, to: :eventdate, allow_nil: true

 acts_as_list scope: :eventdate
  scope :ordered, -> { order(:position) }
end
