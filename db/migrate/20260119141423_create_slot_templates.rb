class CreateSlotTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :slot_templates do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :day_of_week
      t.time :time_start
      t.time :time_end
      t.integer :repeat_rule
      t.integer :repeat_every
      t.date :repeat_start
      t.date :repeat_end
      t.string :seasons
      t.string :jsonb
      t.string :color_hex
      t.references :taxbranch, null: true, foreign_key: true

      t.timestamps
    end
  end
end
