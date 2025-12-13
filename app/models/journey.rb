class Journey < ApplicationRecord
   belongs_to :taxbranch, optional: true
  belongs_to :service,   optional: true
  belongs_to :lead,      optional: true

  belongs_to :template_journey,
             class_name: "Journey",
             optional: true
  has_many :child_journeys,
           class_name: "Journey",
           foreign_key: :template_journey_id,
           dependent: :nullify

  # 👇 relazioni corrette
  has_many :eventdates, dependent: :destroy
  has_many :commitments, through: :eventdates

  has_many :enrollments, dependent: :destroy
  has_many :bookings, through: :enrollments
  has_many :certificates, dependent: :restrict_with_exception

  validates :slug, presence: true, uniqueness: true

  before_validation :ensure_slug!



  enum :importance, { low: 0, normal: 1, high: 2, critical: 3 }
  enum :urgency,    { relaxed: 0, soon: 1, urgent: 2, asap: 3 }
  enum :energy,     { low_energy: 0, medium_energy: 1, high_energy: 2 }
  enum :kind, {
    draft: 0,          # lo sto pensando
    template: 1,       # è il modello valido
    instance_cycle: 2  # ciclo reale basato su un template
  }

  store_accessor :meta, :color, :visibility, :tags

  # 👇 aggiungiamo scope “di data”
  scope :ordered_by_created, -> { order(created_at: :desc) }
  scope :ordered_by_updated, -> { order(updated_at: :desc) }
  scope :ordered, -> { order(created_at: :desc) }
  # fine aggiunta scope
  # # ⚙️ Fase corrente in base alle date compilate
  def current_stage
    return :complete    if complete.present?
    return :erogation   if start_erogation.present?
    return :realized    if start_realized.present?
    return :ideate      if start_ideate.present?

    :planning
  end

  # 📅 Data “giusta” da mostrare per la fase
  def current_stage_date
    case current_stage
    when :complete   then complete
    when :erogation  then start_erogation
    when :realized   then start_realized
    when :ideate     then start_ideate
    else
      created_at
    end
  end

  # 🧠 Etichetta umana per la fase
  def human_stage
    {
      planning:  "Da pianificare",
      ideate:    "In idea",
      realized:  "In costruzione",
      erogation: "In erogazione",
      complete:  "Completato"
    }[current_stage]
  end

  # 📊 Avanzamento: se `progress` è impostato lo usa,
  # altrimenti lo calcola in base alle tappe
  def computed_progress
    return progress if progress.present?

    steps = [
      start_ideate.present?,
      start_realized.present?,
      start_erogation.present?,
      complete.present?
    ]

    done = steps.count { |x| x }
    (done * 25).clamp(0, 100) # 0,25,50,75,100
  end
  def ordered_eventdates
    if draft?
      eventdates.distinct.order(date_start: :desc)
    else
      eventdates.distinct.order(date_start: :asc)
    end
  end

  private

  def ensure_slug!
    return if slug.present?

    base = (title.presence || "journey-#{SecureRandom.hex(3)}").parameterize
    self.slug = base.presence || "journey-#{SecureRandom.hex(3)}"
  end
end
