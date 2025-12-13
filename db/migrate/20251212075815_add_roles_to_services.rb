class AddRolesToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :allowed_roles, :jsonb, default: [], null: false
    add_column :services, :output_roles,  :jsonb, default: [], null: false
  end
end
