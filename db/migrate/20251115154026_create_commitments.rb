class CreateCommitments < ActiveRecord::Migration[8.1]
  def change
    create_table :commitments do |t|
      t.references :eventdate, null: false, foreign_key: true
      t.references :template_commitment, foreign_key: { to_table: :commitments } # opzionale, per tracciare l’origine

      t.string  :role_name
      t.integer :role_count
      t.integer :commitment_kind, default: 0, null: false

      t.string  :area
      t.integer :duration_minutes
      t.decimal :compensation_dash,  precision: 16, scale: 8
      t.decimal :compensation_euro,  precision: 8,  scale: 2
      t.integer :importance
      t.integer :urgency
      t.integer :energy
      t.integer :position
      t.bigint  :taxbranch_id
      t.jsonb   :meta, default: {}, null: false
      t.timestamps
    end
  end
end
