# db/migrate/20251029100000_create_leads.rb
class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.string  :name
      t.string  :surname
      t.string  :username, null: false
      t.string  :email, null: false          # email obbligatoria come richiesto
      t.string  :phone
      t.string  :token, null: false
      t.references :user, null: true, foreign_key: true
      t.integer :parent_id
      t.integer :referral_lead_id
      t.jsonb   :meta, default: {}

      t.timestamps
    end

    add_index :leads, :token, unique: true
    add_index :leads, :parent_id
    add_index :leads, :referral_lead_id
    add_index :leads, :email
    add_index :leads, :username, unique: true
  end
end
