class AddSlugToJourneys < ActiveRecord::Migration[8.1]
  def change
    add_column :journeys, :slug, :string
    add_index :journeys,  :slug, unique: true
  end
end
