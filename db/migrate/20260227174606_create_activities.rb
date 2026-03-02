class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true
      t.references :taxbranch, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true
      t.references :enrollment, null: false, foreign_key: true
      t.references :eventdate, null: false, foreign_key: true
      t.references :certificate, null: false, foreign_key: true
      t.string :kind
      t.string :status
      t.datetime :occurred_at
      t.jsonb :payload
      t.integer :score_total
      t.integer :score_max
      t.string :level_code
      t.string :source
      t.string :source_ref

      t.timestamps
    end
  end
end
