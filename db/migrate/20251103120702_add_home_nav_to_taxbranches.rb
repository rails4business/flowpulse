class AddHomeNavToTaxbranches < ActiveRecord::Migration[8.0]
  def change
    add_column :taxbranches, :positioning_tag_public, :boolean, default: false, null: false
    add_index  :taxbranches, :positioning_tag_public
    add_column :taxbranches, :home_nav, :boolean, default: false
    add_index :taxbranches, :home_nav
  end
end
