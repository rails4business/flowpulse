class Taxbranch < ApplicationRecord
  has_ancestry
  acts_as_list scope: [ :ancestry ]
  belongs_to :lead, optional: true
  has_many :tag_positionings, dependent: :destroy
  has_one  :post, inverse_of: :taxbranch, dependent: :destroy
  has_many :domains
   has_many :eventdates, dependent: :destroy

  # ✅ NON blocchiamo più su lista fissa
  validates :slug_category, presence: true
  validates :slug_label,    presence: true
  validates :slug,          presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_and_build_slugs
  after_commit :bust_categories_cache, if: :saved_change_to_slug_category?

  scope :roots,         -> { where(ancestry: nil).order(:position, :slug_label) }
  scope :ordered,       -> { order(:position, :slug_label) }
  scope :home_nav,      -> { where(home_nav: true).ordered }
  scope :positioning_on, -> { where(positioning_tag_public: true) }

  # 🧠 Suggerimenti categorie (cached)
  def self.category_suggestions
    Rails.cache.fetch("taxbranch:slug_categories:v1", expires_in: 1.hour) do
      where.not(slug_category: [ nil, "" ])
        .distinct
        .order(:slug_category)
        .pluck(:slug_category)
    end
  end

  def has_post?        = post.present?
  def has_public_post? = post&.published?
  def display_label    = slug_label.presence || slug.to_s.titleize
  def effective_domain_taxbranch
    # ordine: self, poi parent, poi parent del parent, ... fino alla root
    ids = [ id ] + ancestor_ids.reverse

    # pre-carica i record (e i domini) in un colpo solo
    tb_map = Taxbranch.where(id: ids).includes(:domains).index_by(&:id)

    ids.each do |tid|
      tb = tb_map[tid]
      next unless tb

      # se :domains è pre-caricato, usa any?, altrimenti exists?
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
  private

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
