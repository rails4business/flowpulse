class RemoveLegacyStageDatesFromJourneys < ActiveRecord::Migration[8.1]
  def change
    remove_column :journeys, :start_ideate, :datetime
    remove_column :journeys, :start_realized, :datetime
    remove_column :journeys, :start_erogation, :datetime
    remove_column :journeys, :complete, :datetime
  end
end
