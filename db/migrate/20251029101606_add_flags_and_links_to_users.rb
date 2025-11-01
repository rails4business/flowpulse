class AddFlagsAndLinksToUsers < ActiveRecord::Migration[8.0]
  # db/migrate/20251029100500_add_flags_and_links_to_users.rb
  def change
    add_column :users, :state_registration, :integer, null: false, default: 0  # 0=pending, 1=approved
    add_column :users, :superadmin, :boolean, null: false, default: false
    add_reference :users, :lead, foreign_key: { to_table: :leads }, null: true
    add_column :users, :approved_at, :datetime
    add_reference :users, :approved_by_lead, foreign_key: { to_table: :leads }, null: true
    add_column :users, :last_active_at, :datetime
    add_index :users, :state_registration
  end
end
