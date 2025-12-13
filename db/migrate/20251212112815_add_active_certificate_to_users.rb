class AddActiveCertificateToUsers < ActiveRecord::Migration[8.1]
    def change
    add_column :users, :active_certificate_id, :integer
    add_index  :users, :active_certificate_id
    add_foreign_key :users, :certificates, column: :active_certificate_id
  end
end
