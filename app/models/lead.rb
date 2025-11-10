# app/models/lead.rb
class Lead < ApplicationRecord
  belongs_to :user, optional: true, inverse_of: :lead
  has_many :taxbranches
  has_many :posts, inverse_of: :lead, dependent: :nullify

  has_many :tag_positionings, dependent: :destroy


  belongs_to :parent,        class_name: "Lead", optional: true
  belongs_to :referral_lead, class_name: "Lead", optional: true
  has_many   :children,      class_name: "Lead", foreign_key: :parent_id, dependent: :nullify

  validates :username,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-zA-Z0-9._\-]+\z/ },
    if: -> { self.respond_to?(:username) && username.present? && self.class.column_names.include?("username") }

    validates :token,    presence: true, uniqueness: true

  before_validation :ensure_token

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(20)
  end

  def full_name
    [ name, surname ].compact_blank.join(" ")
  end
end
