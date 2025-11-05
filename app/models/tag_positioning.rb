# app/models/tag_positioning.rb
class TagPositioning < ApplicationRecord
   belongs_to :lead
  belongs_to :taxbranch
  belongs_to :post, optional: true
  has_many :taxbranches


  validates :name, :category, presence: true

  scope :for_taxbranch, ->(tb) { where(taxbranch_id: tb) }
  scope :categories_for, ->(tb) { for_taxbranch(tb).distinct.order(:category).pluck(:category) }
end
