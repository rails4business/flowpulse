class AddPhaseToJourneys < ActiveRecord::Migration[8.1]
  def change
    add_column :journeys, :phase, :integer, default: 0, null: false
    add_column :taxbranches, :phase, :integer, default: 0, null: false
    add_column :enrollments, :phase, :integer, default: 0, null: false
    add_column :services, :enrollable_until_phase, :integer
    add_column :services, :enrollable_from_phase, :integer
  end
end
