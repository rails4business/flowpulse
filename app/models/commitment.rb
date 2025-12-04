class Commitment < ApplicationRecord
  belongs_to :journey
  belongs_to :taxbranch, optional: true
  belongs_to :eventdate, optional: true

  has_many :bookings


  enum :commitment_kind, {
    internal_task: 0,
    operator_role: 1,
    client_commitment: 2,
    event_session: 3
  }

 acts_as_list scope: :eventdate
  scope :ordered, -> { order(:position) }
end
