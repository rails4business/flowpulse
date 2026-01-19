class AddJourneyRolesToJourneysEventdatesEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :journeys, :journey_roles, :jsonb, default: [], null: false
    add_column :eventdates, :journey_role, :string
    add_column :enrollments, :journey_role, :string
    add_column :bookings, :journey_role, :string
  end
end
