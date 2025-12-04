class CreateJourneys < ActiveRecord::Migration[8.1]
  def change
    create_table :journeys do |t|
      t.string :title
      t.references :taxbranch, null: true, foreign_key: true
      t.references :service, null: true, foreign_key: true
      t.references :lead, null: false, foreign_key: true
      t.integer :importance
      t.integer :urgency
      t.integer :energy
      t.integer :progress
      t.text :notes
      t.decimal :price_estimate_euro, precision: 8, scale: 2
      t.decimal :price_estimate_dash, precision: 16, scale: 8
      t.jsonb :meta, null: false, default: {}

      t.integer :kind, null: false, default: 0
      t.references :template_journey, foreign_key: { to_table: :journeys }
      t.datetime :start_ideate
      t.datetime :start_realized
      t.datetime :start_erogation
      t.datetime :complete

      t.timestamps
    end
  end
end
