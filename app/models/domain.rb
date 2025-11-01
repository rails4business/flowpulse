class Domain < ApplicationRecord
  belongs_to :taxbranch


  validates :host, presence: true, uniqueness: { case_sensitive: false }
  validates :language, presence: true


  before_validation :normalize_host!

  private

  def normalize_host!
    return if host.blank?
    h = host.to_s.strip.downcase
    h = h.sub(/\Ahttps?:\/\//, "")
    h = h.sub(/\Awww\./, "")
    h = h.split(":").first
    self.host = h
  end
end
