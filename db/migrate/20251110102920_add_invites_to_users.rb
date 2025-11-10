class AddInvitesToUsers < ActiveRecord::Migration[8.1]
 def change
    add_column :users, :invites_count, :integer, default: 0, null: false
    add_column :users, :invites_limit, :integer, default: 7, null: false
    add_column :users, :referrer_id, :integer
    add_index  :users, :referrer_id
  end
end
