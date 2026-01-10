class AddSuperadminModeActiveToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :superadmin_mode_active, :boolean, default: false, null: false
  end
end
