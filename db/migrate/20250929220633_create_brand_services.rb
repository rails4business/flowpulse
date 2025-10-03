class CreateBrandServices < ActiveRecord::Migration[8.0]
  def change
    create_table :brand_services do |t|
      t.references :brand,       null: false, foreign_key: true
      t.references :service_def, null: false, foreign_key: true
      t.timestamps
    end
  add_index :brand_services, [ :brand_id, :service_def_id ], unique: true
  end
end
