class RenameRoleAreasOnDomains < ActiveRecord::Migration[8.1]
  def change
    rename_column :domains, :role_areas, :operative_roles
  end
end
