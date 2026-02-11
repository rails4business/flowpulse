class CreateDomainMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :domain_memberships do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true
      t.integer :status
      t.boolean :primary
      t.string :domain_active_role, null: false, default: "member"

      t.timestamps
    end
  end
end
