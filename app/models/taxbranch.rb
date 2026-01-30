class Taxbranch < ApplicationRecord
  has_ancestry
  acts_as_list scope: [ :ancestry ]


  belongs_to :lead, optional: true

  has_many :tag_positionings, dependent: :destroy
  has_one  :post, inverse_of: :taxbranch, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :eventdates, dependent: :destroy
  has_one :service, dependent: :restrict_with_error
  has_many :journeys, dependent: :destroy
  has_many :incoming_journeys, class_name: "Journey", foreign_key: :end_taxbranch_id, dependent: :nullify
  has_many :certificates, dependent: :restrict_with_exception

  # 🔗 Self-link: un taxbranch può fare da "link" verso un altro taxbranch
  belongs_to :link_child,
             class_name: "Taxbranch",
             foreign_key: :link_child_taxbranch_id,
             optional: true

  # Tutti i taxbranch che mi usano come link_child
  has_many :linked_parents,
           class_name: "Taxbranch",
           foreign_key: :link_child_taxbranch_id,
           inverse_of: :link_child,
           dependent: :nullify

  # ✅ validazioni slug
  validates :slug_category, presence: true
  validates :slug_label,    presence: true
  validates :slug,          presence: true, uniqueness: { case_sensitive: false }

  validate :cannot_have_children_if_link_node
  validate :permission_roles_must_match_domain
  before_validation :normalize_and_build_slugs
  after_commit :bust_categories_cache, if: :saved_change_to_slug_category?

  enum :status, {
    draft:     0,
    in_review: 1,
    published: 2,
    archived:  3
  }

  enum :visibility, {
    private_node:      0,  # visibile solo a superadmin e lead proprietario
    shared_node:       1,  # visibile allo staff, ma non pubblica
    participants_only: 2,  # visibile agli utenti iscritti a un percorso
    public_node:       3,   # visibile a tutti, come pagine pubbliche e blog
    hide_node: 4,
    hide_children: 5,
    hide_both: 6,  #
    voice_menu: 7
  }

  enum :phase, {
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

  scope :roots,          -> { where(ancestry: nil).order(:position, :slug_label) }
  scope :ordered,        -> { order(:position, :slug_label) }
  scope :positioning_on, -> { where(positioning_tag_public: true) }
  scope :home_nav, -> { where(home_nav: true) }

  # 🚉 Service Stations: Taxbranches that host a Service
  scope :service_stations, -> { joins(:service) }

  def service_station?
    service.present?
  end

  # 🧠 Suggerimenti categorie (cached)
  def self.category_suggestions
    Rails.cache.fetch("taxbranch:slug_categories:v1", expires_in: 1.hour) do
      where.not(slug_category: [ nil, "" ])
        .distinct
        .order(:slug_category)
        .pluck(:slug_category)
    end
  end



  # 🔍 helper vari
  def has_post?        = post.present?
  def has_public_post? = post&.published?
  def display_label    = slug_label.presence || slug.to_s.titleize

  def permission_access_roles=(value)
    self[:permission_access_roles] = normalize_role_list(value)
  end

  def permission_access_roles_text
    Array(permission_access_roles).join("\n")
  end

  def available_permission_roles
    Array(header_domain&.role_areas).filter_map { |role| role.to_s.strip.presence }.uniq
  end

  def header_domain_taxbranch
    ids   = [ id ] + ancestor_ids.reverse
    tb_map = Taxbranch.where(id: ids).includes(:domains).index_by(&:id)

    ids.each do |tid|
      tb = tb_map[tid]
      next unless tb

      has_domains =
        if tb.association(:domains).loaded?
          tb.domains.any?
        else
          tb.domains.exists?
        end

      return tb if has_domains
    end

    nil
  end

  alias_method :effective_domain_taxbranch, :header_domain_taxbranch

  def effective_domain
    header_domain_taxbranch&.domains&.first
  end

  def header_domain
    @header_domain ||= effective_domain
  end

  def header_domain_id
    header_domain&.id
  end

  scope :public_published_ordered, -> {
    where(
      status:     statuses[:published],
      visibility: visibilities[:public_node]
    ).where(
      arel_table[:published_at].eq(nil)
        .or(arel_table[:published_at].lteq(Time.current))
    ).order(Arel.sql("COALESCE(published_at, created_at) DESC"))
  }

  def public_and_published?
    published? &&
      public_node? &&
      (published_at.nil? || published_at <= Time.current)
  end

  def visible_and_published_for?(lead)
    return false unless public_and_published?

    case visibility.to_sym
    when :public_node
      true
    when :participants_only
      lead&.participates_in?(self)
    when :shared_node
      lead&.staff? || lead&.superadmin?
    when :private_node
      lead&.id == lead_id
    else
      false
    end
  end

 # 👉 Nodo-link sì/no
 def link_node?
  link_child.present?
end

  # 🔗 figli di navigazione
  # - se il nodo è un link, usa i figli del link_child
  # - altrimenti usa i figli normali
  def nav_children
    target = link_node? ? link_child : self
    target.children.to_a.map { |child| NavNode.new(child) }
  end

  private

  def cannot_have_children_if_link_node
    return unless link_node?
    return if children.empty?

    errors.add(:base, "Un taxbranch che fa da link non può avere figli reali.")
  end

  def bust_categories_cache
    Rails.cache.delete("taxbranch:slug_categories:v1")
  end

  def normalize_and_build_slugs
    raw_category = slug_category.to_s
    raw_label    = slug_label.to_s

    self.slug_category = raw_category.parameterize.presence || "branch"
    self.slug_label    = raw_label.strip.presence || raw_category

    label_for_slug = ActiveSupport::Inflector.transliterate(self.slug_label)
                                             .parameterize
    base = [ slug_category, label_for_slug ].reject(&:blank?).join("/")
    self.slug = unique_slug_for(base.presence || SecureRandom.hex(4))
  end

  def unique_slug_for(base)
    rel = Taxbranch.where.not(id: id)
    candidate = base
    i = 2
    while rel.exists?(slug: candidate)
      candidate = "#{base}/#{i}"
      i += 1
    end
    candidate
  end

  def normalize_role_list(value)
    list =
      case value
      when String
        value.split(/[\n,;]/)
      when Array
        value
      else
        Array(value)
      end

    list.filter_map { |entry| entry.to_s.strip.presence }.uniq
  end

  def permission_roles_must_match_domain
    return if permission_access_roles.blank?

    available = available_permission_roles
    return if available.blank?

    invalid = permission_access_roles - available
    return if invalid.blank?

    errors.add(
      :permission_access_roles,
      "contiene valori non presenti tra i ruoli disponibili del dominio: #{invalid.join(', ')}"
    )
  end
end
