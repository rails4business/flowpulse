class AddCenterTaxbranchToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :taxbranches, :public_address, :text
    add_column :taxbranches, :private_address, :text
    add_column :taxbranches, :address_privacy, :string, null: false, default: "private"

    add_index :taxbranches, :address_privacy
  end
end
