class AddGeneraimpresaMdToTaxbranches < ActiveRecord::Migration[8.1]
  def change
    add_column :taxbranches, :generaimpresa_md, :text
  end
end
