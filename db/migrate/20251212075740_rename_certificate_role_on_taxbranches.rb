class RenameCertificateRoleOnTaxbranches < ActiveRecord::Migration[8.1]
  def change
    remove_column :taxbranches, :certificate_role, :string
    add_column :taxbranches, :permission_access_roles, :jsonb, default: [], null: false
  end
end
