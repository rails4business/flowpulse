class Journey < ApplicationRecord
  enum :journeys_status, {
    problema: 0,
    obiettivo: 1,
    previsione: 2,
    responsabile_progettazione: 3,
    step_necessari: 4,
    impegno: 5,
    realizzazione: 6,
    test: 7,
    attivo: 8,
    chiuso: 9
  }, prefix: true
  belongs_to :taxbranch, optional: true
  belongs_to :end_taxbranch, class_name: "Taxbranch", optional: true
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
  validate :unique_endpoint_pair, on: :create

  before_validation :ensure_slug!


  enum :importance, { low: 0, normal: 1, high: 2, critical: 3 }
  enum :urgency,    { relaxed: 0, soon: 1, urgent: 2, asap: 3 }
  enum :energy,     { low_energy: 0, medium_energy: 1, high_energy: 2 }
  enum :kind, {
    idea: 0,  # solo idea
    task: 1,  # solo task
    milestone: 2, # solo obiettivo:
    process: 3, # attività in
    cycle_template: 4,       # è il modello valido
    cycle_instance: 5,  # ciclo reale basato su un template
    activity: 6  # attività generica
  }
  # journey_type meanings:
  # - work: lavoro interno "costruttori"
  # - formazione: lavoro interno per professionisti/erogatori
  # - health: percorso/evento erogato ai clienti
  enum :journey_type, { work: 0, health: 1, formazione: 2 }

  store_accessor :meta, :color, :visibility, :tags

  def journey_roles_text
    Array(journey_roles).join("\n")
  end

  def journey_roles_text=(value)
    list =
      case value
      when String
        value.split(/[\n,;]/)
      when Array
        value
      else
        Array(value)
      end

    self.journey_roles = list.filter_map { |entry| entry.to_s.strip.presence }.uniq
  end

  # Back-compat helpers for older view naming


  # 👇 aggiungiamo scope “di data”
  scope :ordered_by_created, -> { order(created_at: :desc) }
  scope :ordered_by_updated, -> { order(updated_at: :desc) }
  scope :ordered, -> { order(created_at: :desc) }
  
  # 🚄 Service Rails: Journeys connecting two Services (Station -> Station)
  scope :service_rails, -> {
    joins(taxbranch: :service, end_taxbranch: :service)
  }

  # 🛤️ Connecting Rails: Journeys that are NOT Service Rails (e.g. Service -> Generic)
  scope :connecting_rails, -> {
    where.not(id: service_rails)
  }
  # fine aggiunta scope
  # # ⚙️ Fase corrente in base alle date compilate
  def current_stage
    return :complete if end_at.present?
    return :active if start_at.present?

    :planning
  end

  # 📅 Data “giusta” da mostrare per la fase
  def current_stage_date
    case current_stage
    when :complete then end_at
    when :active then start_at
    else
      created_at
    end
  end

  # 🧠 Etichetta umana per la fase
  def human_stage
    {
      planning: "Da pianificare",
      active: "In corso",
      complete: "Completato"
    }[current_stage]
  end

  # 📊 Avanzamento: se `progress` è impostato lo usa,
  # altrimenti lo calcola in base alle tappe
  def computed_progress
    return progress if progress.present?
    return 100 if end_at.present?
    return 50 if start_at.present?

    0
  end
  def ordered_eventdates
    if process?
      eventdates.distinct.order(date_start: :desc)
    else
      eventdates.distinct.order(date_start: :asc)
    end
  end

  def station_service_start
    Service.find_by(taxbranch_id: taxbranch_id)
  end

  def station_service_end
    Service.find_by(taxbranch_id: end_taxbranch_id)
  end

  def railservice?
    station_service_start.present? && station_service_end.present?
  end

  def journey_function?
    station_service_start.present? && station_service_end.blank?
  end

  private

  def ensure_slug!
    return if slug.present?

    base = (title.presence || "journey-#{SecureRandom.hex(3)}").parameterize
    self.slug = base.presence || "journey-#{SecureRandom.hex(3)}"
  end

  def unique_endpoint_pair
    return if taxbranch_id.blank? || end_taxbranch_id.blank?

    if Journey.where(taxbranch_id: taxbranch_id, end_taxbranch_id: end_taxbranch_id).exists?
      errors.add(:base, "Esiste già un journey con la stessa stazione di partenza e arrivo.")
    end
  end
end
