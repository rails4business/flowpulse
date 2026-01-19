class AddRoleGroupsToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :builders_roles, :jsonb, default: [], null: false
    add_column :services, :drivers_roles, :jsonb, default: [], null: false
  end
end
