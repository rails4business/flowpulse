class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.integer :n_eventdates_planned
      t.decimal :price_enrollment_euro, precision: 8, scale: 2
      t.decimal :price_ticket_dash, precision: 16, scale: 8
      t.integer :min_tickets
      t.integer :max_tickets
      t.boolean :open_by_journey
      t.references :taxbranch, null: false, foreign_key: true
      t.references :lead, null: false, foreign_key: true
      t.jsonb :meta, null: false, default: {}

      t.timestamps
    end
  end
end
