class DropLeadsUserId < ActiveRecord::Migration[8.1]
  def up
    # Se avevi FK/indice, remove_reference li gestisce
    remove_reference :leads, :user, foreign_key: true if column_exists?(:leads, :user_id)
  end

  def down
    add_reference :leads, :user, foreign_key: true
    # opzionale: ripristino coerente dal legame users.lead_id
    execute <<~SQL
      UPDATE leads l
      SET user_id = u.id
      FROM users u
      WHERE u.lead_id = l.id
        AND l.user_id IS NULL;
    SQL
  end
end
