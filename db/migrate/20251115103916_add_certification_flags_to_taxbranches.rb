class AddCertificationFlagsToTaxbranches < ActiveRecord::Migration[8.1]
  def change
    add_column :taxbranches, :service_certificable, :boolean
    add_column :taxbranches, :certificate_role, :string
    add_column :taxbranches, :status,      :integer, null: false, default: 0
    add_column :taxbranches, :visibility,  :integer, null: false, default: 0
    add_column :taxbranches, :published_at, :datetime
    add_column :taxbranches, :scheduled_at, :datetime
    remove_column :posts, :published_at, :datetime
    remove_column :posts, :scheduled_at, :datetime
    remove_column :posts, :status,      :integer
  end
end
