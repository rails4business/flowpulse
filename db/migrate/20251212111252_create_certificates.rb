class CreateCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :certificates do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :datacontact, null: false, foreign_key: true
      t.references :enrollment, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.references :journey, null: false, foreign_key: true
      t.references :taxbranch, null: false, foreign_key: true
      t.string :role_name
      t.integer :status
      t.datetime :issued_at
      t.datetime :expires_at
      t.integer :issued_by_enrollment_id
      t.jsonb :meta

      t.timestamps
    end
    add_foreign_key :certificates, :enrollments, column: :issued_by_enrollment_id
  end
end
