class CreateMycontacts < ActiveRecord::Migration[8.1]
  def change
    create_table :mycontacts do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :datacontact, null: false, foreign_key: true
      t.string :status_contact
      t.datetime :approved_by_referent_at
      t.boolean :original

      t.timestamps
    end
  end
end
