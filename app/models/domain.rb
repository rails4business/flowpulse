class Domain < ApplicationRecord
   store_accessor :aree_ruoli
  belongs_to :taxbranch
  #  belongs_to :owner, class_name: "Lead", optional: true

  validates :host, presence: true, uniqueness: true
  validates :language, presence: true

  before_validation :normalize_host!
  after_commit :clear_cache
  validates :host, presence: true, uniqueness: { case_sensitive: false }
  validates :language, presence: true

  before_validation :normalize_host!
  after_commit :clear_cache

  private

  def normalize_host!
    return if host.blank?

    h = host.to_s.strip.downcase
    h = h.sub(/\Ahttps?:\/\//, "")
    h = h.sub(/\Awww\./, "")
    h = h.split(":").first
    self.host = h
  end

  def clear_cache
    Rails.cache.delete("domain:#{host}")
  end
end
