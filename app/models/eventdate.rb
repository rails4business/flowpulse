class Eventdate < ApplicationRecord
  # Può essere usato come:
  # - evento di calendario (solo date + location + journey opzionale)
  # - log/diario (taxbranch + lead + cycle + status)

  # 🔗 Relazioni
  belongs_to :journey,   optional: true
  belongs_to :taxbranch, optional: true
  belongs_to :lead,      optional: true

  has_many :commitments,    dependent: :destroy
  has_many :bookings, dependent: :destroy

  # 🎭 Tipologia / meta-evento
  enum :event_type, { session: 0, meeting: 1, online_call: 2, recording: 3 }
  enum :mode,       { onsite: 0, online: 1, hybrid: 2 }
  enum :visibility, { internal_date: 0, public_date: 1 }

 # ✅ Stati del "diario"
 enum :status, { pending: 0, tracking: 1, completed: 2, skipped: 3 }


  # 📅 Validazione "da calendario" – sempre sensata
  validates :description, presence: true
  validates :lead, presence: true

  # 📓 Validazioni "da diario" – SOLO se stai usando taxbranch
  with_options if: -> { taxbranch_id.present? } do
    validates :cycle, presence: true, numericality: { greater_than_or_equal_to: 1 }
    validates :status, presence: true
  end
end
