# app/models/lead.rb
class Lead < ApplicationRecord
  has_one :user
  has_many :taxbranches



  belongs_to :parent,        class_name: "Lead", optional: true
  belongs_to :referral_lead, class_name: "Lead", optional: true
  has_many   :children,      class_name: "Lead", foreign_key: :parent_id, dependent: :nullify

  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9._\-]+\z/ }
  validates :token,    presence: true, uniqueness: true

  before_validation :ensure_token

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(20)
  end

  def full_name
    [ name, surname ].compact_blank.join(" ")
  end
end
