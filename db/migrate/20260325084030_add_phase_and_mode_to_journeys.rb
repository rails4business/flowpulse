class AddPhaseAndModeToJourneys < ActiveRecord::Migration[8.1]
  def change
    add_column :journeys, :phase, :string
    add_column :journeys, :mode, :string
  end
end
