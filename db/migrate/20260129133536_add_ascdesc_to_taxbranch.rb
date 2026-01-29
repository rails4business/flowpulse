class AddAscdescToTaxbranch < ActiveRecord::Migration[8.1]
  def change
    add_column :taxbranches, :order_des, :boolean, default: false
  end
end
