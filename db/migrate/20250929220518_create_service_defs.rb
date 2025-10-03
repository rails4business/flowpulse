class CreateServiceDefs < ActiveRecord::Migration[8.0]
  def change
    create_table :service_defs do |t|
      t.string  :key,                     null: false
      t.string  :subdomain,               null: false
      t.string  :original_domain
      t.string  :title
      t.text    :description
      t.string  :image_url
      t.string  :state,                   null: false, default: "develop"
      t.string  :data_source,             null: false, default: "yml" # "yml" o "db"

      t.timestamps
    end
  add_index :service_defs, :key, unique: true
  end
end
