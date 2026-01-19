class AddEndToTaxbranch < ActiveRecord::Migration[8.1]
  def change
    add_column :journeys, :end_taxbranch_id, :integer
    add_index :journeys, :end_taxbranch_id
    add_column :taxbranches, :x_coordinated, :integer
    add_column :taxbranches, :y_coordinated, :integer
  end
end
