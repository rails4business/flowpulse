class Taxbranch < ApplicationRecord
  has_ancestry
  acts_as_list scope: [ :ancestry ]


  belongs_to :lead, optional: true

  has_many :tag_positionings, dependent: :destroy
  has_one  :post, inverse_of: :taxbranch, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :eventdates, dependent: :destroy
  has_many :serices, dependent: :destroy
  has_many :journeys, dependent: :destroy

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
    public_node:       3   # visibile a tutti, come pagine pubbliche e blog
  }

  scope :roots,          -> { where(ancestry: nil).order(:position, :slug_label) }
  scope :ordered,        -> { order(:position, :slug_label) }
  scope :positioning_on, -> { where(positioning_tag_public: true) }
  scope :home_nav, -> { where(home_nav: true) }

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

  def effective_domain_taxbranch
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

  def effective_domain
    effective_domain_taxbranch&.domains&.first
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
    self.slug_category = slug_category.to_s.parameterize
    self.slug_label    = slug_label.to_s.parameterize

    base = [ slug_category, slug_label ].join("/")
    self.slug = unique_slug_for(base)
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
end
