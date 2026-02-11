class AddDomainMembershipToCertificates < ActiveRecord::Migration[8.1]
  def change
    add_reference :certificates, :domain_membership, null: false, foreign_key: true
    add_reference :certificates, :domain, foreign_key: true
    add_index :certificates, [ :domain_membership_id, :role_name ]
  end
end
