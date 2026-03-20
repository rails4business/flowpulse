class AddDomainAndDomainMembershipToEventdates < ActiveRecord::Migration[8.1]
  def up
    add_reference :eventdates, :domain, null: true, foreign_key: true
    add_reference :eventdates, :domain_membership, null: true, foreign_key: true

    execute <<~SQL
      UPDATE eventdates e
      SET domain_id = dm.domain_id,
          domain_membership_id = dm.id
      FROM domain_memberships dm
      WHERE dm.lead_id = e.lead_id
        AND dm.primary = true
        AND (e.domain_id IS NULL OR e.domain_membership_id IS NULL);
    SQL

    execute <<~SQL
      UPDATE eventdates
      SET domain_id = (SELECT id FROM domains ORDER BY id ASC LIMIT 1)
      WHERE domain_id IS NULL;
    SQL

    execute <<~SQL
      UPDATE eventdates
      SET domain_membership_id = (
        SELECT dm.id
        FROM domain_memberships dm
        WHERE dm.lead_id = eventdates.lead_id
        ORDER BY dm.primary DESC, dm.id ASC
        LIMIT 1
      )
      WHERE domain_membership_id IS NULL;
    SQL

    change_column_null :eventdates, :domain_id, false
    change_column_null :eventdates, :domain_membership_id, false
  end

  def down
    remove_reference :eventdates, :domain_membership, foreign_key: true
    remove_reference :eventdates, :domain, foreign_key: true
  end
end
