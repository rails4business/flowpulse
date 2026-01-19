class AddStartEndAtToJourneys < ActiveRecord::Migration[8.1]
  def change
    add_column :journeys, :start_at, :datetime
    add_column :journeys, :end_at, :datetime
  end
end
