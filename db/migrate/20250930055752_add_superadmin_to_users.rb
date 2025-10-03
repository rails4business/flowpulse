class AddSuperadminToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :superadmin, :boolean, null: false, default: false
    add_index :users, :superadmin
  end
end
# bin/rails runner "User.create!(email_address: 'mario@mario.it', password: '123456', superadmin: true)"
#  bin/rails runner "User.find_or_create_by!(email_address: 'mario@mario.it') { |u| u.password = '123456'; u.superadmin = true }"
