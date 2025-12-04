class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.references :lead, null: true, foreign_key: true
      t.string :email
      t.string :phone
      t.date :date_of_birth
      t.string :place_of_birth
      t.string :fiscal_code
      t.string :vat_number
      t.string :billing_name
      t.string :billing_address
      t.string :billing_zip
      t.string :billing_city
      t.string :billing_country
      t.jsonb :meta

      t.timestamps
    end
  end
end
