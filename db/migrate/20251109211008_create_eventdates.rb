class CreateEventdates < ActiveRecord::Migration[8.1]
  def change
    create_table :eventdates do |t|
      t.datetime :date_start
      t.datetime :date_end
      t.references :taxbranch, null: false, foreign_key: true
      t.references :lead, null: false, foreign_key: true
      t.integer :cycle
      t.integer :status
      t.text :description
      t.jsonb :meta

      t.timestamps
    end
  end
end
