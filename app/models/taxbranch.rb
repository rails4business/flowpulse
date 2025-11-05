# app/models/taxbranch.rb
#
#
class Taxbranch < ApplicationRecord
  has_ancestry
  acts_as_list scope: [ :ancestry ]


  belongs_to :lead, optional: true
  has_many :tag_positionings, dependent: :destroy


    has_one :post, inverse_of: :taxbranch, dependent: :destroy


  has_many :domain
  accepts_nested_attributes_for :post




  CATEGORIES = %w[brand percorso corso capitolo lezione ruolo tag blog_creators post_blog].freeze

  validates :slug_category, inclusion: { in: CATEGORIES }
  validates :slug_label,    presence: true
  validates :slug,          presence: true, uniqueness: { case_sensitive: false } # globale

  before_validation :normalize_and_build_slugs

  scope :roots,   -> { where(ancestry: nil).order(:position, :slug_label) }
  scope :ordered, -> { order(:position, :slug_label) }
  scope :home_nav, -> { where(home_nav: true).ordered }
  scope :positioning_on, -> { where(positioning_tag_public: true) }

  def self.category_options
    CATEGORIES.map { |c| [ c.humanize, c ] }
  end


  def has_post?
    post.present?
  end

  def display_label
    slug_label.presence || slug.to_s.titleize
  end

  def positioning_items
    counts = tag_positionings.group(:name, :category).count
    counts.map { |(name, cat), n| { text: name, count: n, cat: cat } }
  end


  def has_public_post?
    post&.published?
  end

  private

  def normalize_and_build_slugs
    # normalizza i due componenti
    self.slug_category = slug_category.to_s.parameterize
    self.slug_label    = slug_label.to_s.parameterize

    base = [ slug_category, slug_label ].join("-")
    self.slug = unique_slug_for(base)
  end

  # rende unico lo slug (globalmente). Se preferisci unicità per categoria,
  # cambia la query in rel = Taxbranch.where(slug_category: slug_category)
  def unique_slug_for(base)
    rel = Taxbranch.all
    rel = rel.where.not(id: id) if persisted?

    candidate = base
    i = 2
    while rel.exists?(slug: candidate)
      candidate = "#{base}-#{i}"
      i += 1
    end
    candidate
  end
end
