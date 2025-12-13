class Domain < ApplicationRecord
  store_accessor :aree_ruoli
  belongs_to :taxbranch
  has_many :rails4b_taxbranches,
           class_name: "Taxbranch",
           foreign_key: :rails4b_target_domain_id,
           dependent: :nullify
  #  belongs_to :owner, class_name: "Lead", optional: true

  validates :host, presence: true, uniqueness: true
  validates :language, presence: true

  before_validation :normalize_host!
  after_commit :clear_cache
  validates :host, presence: true, uniqueness: { case_sensitive: false }
  validates :language, presence: true

  before_validation :normalize_host!
  after_commit :clear_cache

  def role_areas=(value)
    parsed =
      case value
      when String
        value.split(/[\n,;]/).map { |entry| entry.strip.presence }.compact
      when Array
        value.map { |entry| entry.to_s.strip.presence }.compact
      else
        value
      end

    super(parsed)
  end

  def role_areas_text
    Array(role_areas).join("\n")
  end

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
