class Taxbranch < ApplicationRecord
  has_ancestry
  acts_as_list scope: [ :ancestry ]
  belongs_to :lead, optional: true
  has_many :tag_positionings, dependent: :destroy
  has_one  :post, inverse_of: :taxbranch, dependent: :destroy
  has_many :domains

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

  private

  def bust_categories_cache
    Rails.cache.delete("taxbranch:slug_categories:v1")
  end

  def normalize_and_build_slugs
    self.slug_category = slug_category.to_s.parameterize
    self.slug_label    = slug_label.to_s.parameterize

    base = [ slug_category, slug_label ].join("-")
    self.slug = unique_slug_for(base)
  end

  def unique_slug_for(base)
    rel = Taxbranch.where.not(id: id)
    candidate = base
    i = 2
    while rel.exists?(slug: candidate)
      candidate = "#{base}-#{i}"
      i += 1
    end
    candidate
  end
end
