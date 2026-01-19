class AddJourneyTypeToJourneys < ActiveRecord::Migration[8.1]
  def change
    add_column :journeys, :journey_type, :integer, default: 0
  end
end
