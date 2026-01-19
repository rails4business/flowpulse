class Eventdate < ApplicationRecord
  # Può essere usato come:
  # - evento di calendario (solo date + location + journey opzionale)
  # - log/diario (taxbranch + lead + cycle + status)

  # 🔗 Relazioni
  belongs_to :journey,   optional: true
  belongs_to :taxbranch, optional: true
  belongs_to :lead,      optional: true
  belongs_to :parent_eventdate, class_name: "Eventdate", optional: true
  has_many   :child_eventdates,
             class_name: "Eventdate",
             foreign_key: :parent_eventdate_id,
             dependent: :nullify

  has_many :commitments,    dependent: :destroy
  has_many :bookings, dependent: :destroy

  acts_as_list scope: :journey

  # 🎭 Tipologia / meta-evento
  enum :event_type, { check: 0,  event: 1, prenotation: 2, message: 3, comment: 4, note: 5 }
  # ✅ Stati del "diario"
  enum :status, { pending: 0, tracking: 1, completed: 2, skipped: 3, archived: 4 }
  enum :kind_event, { session: 0, meeting: 1, online_call: 2, focus: 3, recovery: 4   }
  enum :unit_duration, { minutes: 0, hours: 1, days: 2 }

  enum :mode,       { onsite: 0, online: 1, hybrid: 2 }
  enum :visibility, { internal_date: 0, public_date: 1 }




  # 📅 Validazione "da calendario" – sempre sensata
  validates :description, presence: true
  validates :lead, presence: true

  # 📓 Validazioni "da diario" – SOLO se stai usando taxbranch
  with_options if: -> { taxbranch_id.present? } do
    # validates :cycle, presence: true, numericality: { greater_than_or_equal_to: 1 }
    validates :status, presence: true
  end

  before_validation :apply_duration_to_end_at

  private

  def apply_duration_to_end_at
    return if date_end.present?
    return if date_start.blank? || time_duration.blank? || unit_duration.blank?

    multiplier =
      case unit_duration
      when "minutes" then 1.minute
      when "hours" then 1.hour
      when "days" then 1.day
      else
        nil
      end
    return unless multiplier

    self.date_end = date_start + time_duration.to_i * multiplier
  end
end
