class RenameJourneyPhaseToJourneysStatus < ActiveRecord::Migration[8.1]
  def change
    rename_column :journeys, :phase, :journeys_status
  end
end
