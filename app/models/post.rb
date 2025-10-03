# /onlinecourses/courses/:content_slug/lessons/:lesson_slug
class Post < ApplicationRecord
  belongs_to :user

enum :visibility, {
    pub: 0,          # era :public
    priv: 1,         # era :private
    subscribe: 2
  }

  enum :state, {
    draft: 0,
    review: 1,
    published: 2,
    archived: 3
  }

  validates :title, :slug, :service_key, presence: true
  validates :slug, uniqueness: true

  before_validation :ensure_slug

  scope :for_blog,   -> { where(service_key: "blog") }
  scope :for_domain, ->(d) { where("? = ANY(domains)", d) }
  scope :for_sub,    ->(s) { where(subdomain: s.to_s) }
  scope :ordered,    -> { order(Arel.sql("COALESCE(position, 999999), published_at DESC NULLS LAST, id DESC")) }
  scope :published,  -> { where(state: :published) }

  private

  def ensure_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
