class CreateSlotInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :slot_instances do |t|
      t.references :slot_template, null: false, foreign_key: true
      t.datetime :date_start
      t.datetime :date_end
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
