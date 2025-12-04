class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :service,    null: true,  foreign_key: true
      t.references :eventdate,  null: false, foreign_key: true
      t.references :enrollment, null: true,  foreign_key: true
      t.references :commitment, null: true, foreign_key: true
      t.references :contact,    null: false, foreign_key: true


      t.integer :status,           null: false, default: 0
      t.integer :mode,             null: false, default: 0
      t.integer :participant_role, null: false, default: 0

      t.references :requested_by_lead, null: true,
                                          foreign_key: { to_table: :leads }
      t.references :invited_by_lead,   null: true,
                                          foreign_key: { to_table: :leads }

      t.decimal :price_euro, precision: 10, scale: 2
      t.decimal :price_dash, precision: 16, scale: 8

      t.text  :notes
      t.jsonb :meta, default: {}

      t.timestamps
    end
  end
end
