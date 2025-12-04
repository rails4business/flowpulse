class CreatePayments < ActiveRecord::Migration[8.1]
  def change
   create_table :payments do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :payable, polymorphic: true, null: false

      t.integer :method, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :kind,   null: false, default: 0

      t.decimal :amount_euro,      precision: 10, scale: 2
      t.decimal :amount_dash,      precision: 16, scale: 8
      t.string  :currency,         default: "EUR"

      t.string   :external_id
      t.datetime :paid_at

      t.decimal  :refund_amount_euro, precision: 10, scale: 2
      t.datetime :refund_due_at

      t.references :parent_payment, foreign_key: { to_table: :payments }

      t.text  :notes
      t.jsonb :meta, default: {}

      t.timestamps
    end
  end
end
