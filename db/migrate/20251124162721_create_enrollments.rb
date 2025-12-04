class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
     create_table :enrollments do |t|
      t.references :service, null: true, foreign_key: true
      t.references :journey, null: true, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.string  :role_name
      t.integer :status,       null: false, default: 0
      t.integer :mode,         null: false, default: 0
      t.integer :request_kind, null: false, default: 0

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
