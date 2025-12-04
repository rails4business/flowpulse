class AddLinkToTaxbranch < ActiveRecord::Migration[8.1]
  def change
    add_reference :taxbranches,
                  :link_child_taxbranch,
                  foreign_key: { to_table: :taxbranches },
                  null: true
  end
end
