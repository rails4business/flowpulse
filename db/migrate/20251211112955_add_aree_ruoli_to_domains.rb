class AddAreeRuoliToDomains < ActiveRecord::Migration[8.1]
  def change
    add_column :domains, :role_areas, :jsonb, default: [], null: true
  end
end
