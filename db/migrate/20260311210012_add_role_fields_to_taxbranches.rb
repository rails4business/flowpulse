class AddRoleFieldsToTaxbranches < ActiveRecord::Migration[8.1]
  def change
    add_column :taxbranches, :performed_by_roles, :jsonb, null: false, default: []
    add_column :taxbranches, :target_roles, :jsonb, null: false, default: []
    add_column :taxbranches, :execution_mode, :string, null: false, default: "both"

    add_index :taxbranches, :performed_by_roles, using: :gin
    add_index :taxbranches, :target_roles, using: :gin
    add_index :taxbranches, :execution_mode
  end
end
