class HardenDomainMemberships < ActiveRecord::Migration[8.1]
  def up
    change_column_default :domain_memberships, :status, from: nil, to: 0
    change_column_default :domain_memberships, :primary, from: nil, to: false

    execute <<~SQL
      UPDATE domain_memberships
      SET status = 0
      WHERE status IS NULL
    SQL

    execute <<~SQL
      UPDATE domain_memberships
      SET "primary" = FALSE
      WHERE "primary" IS NULL
    SQL

    change_column_null :domain_memberships, :status, false
    change_column_null :domain_memberships, :primary, false

    add_index :domain_memberships, [ :lead_id, :domain_id ], unique: true, name: "idx_domain_memberships_lead_domain_unique"
    add_index :domain_memberships, :lead_id, unique: true, where: "\"primary\" = true", name: "idx_domain_memberships_primary_per_lead"
  end

  def down
    remove_index :domain_memberships, name: "idx_domain_memberships_primary_per_lead"
    remove_index :domain_memberships, name: "idx_domain_memberships_lead_domain_unique"

    change_column_null :domain_memberships, :primary, true
    change_column_null :domain_memberships, :status, true

    change_column_default :domain_memberships, :primary, from: false, to: nil
    change_column_default :domain_memberships, :status, from: 0, to: nil
  end
end
