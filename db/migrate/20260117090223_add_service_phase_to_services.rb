class AddServicePhaseToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :journeys, :service_phase, :integer
  end
end
