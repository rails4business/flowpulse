class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_or_title, use: :slugged

  belongs_to :lead, optional: true
  belongs_to :taxbranch, optional: true

  enum :status, { draft: 0, published: 1, archived: 2 }

  validates :title, presence: true

  scope :published_recent, -> { where(status: :published).order(published_at: :desc) }

  def display_status
    case status
    when "published" then "Pubblicato"
    when "draft" then "Bozza"
    else "Archivio"
    end
  end

  def slug_or_title
    slug.presence || title
  end

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end
end
