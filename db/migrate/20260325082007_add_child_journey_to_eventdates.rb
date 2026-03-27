class AddChildJourneyToEventdates < ActiveRecord::Migration[8.1]
  def change
     add_reference :eventdates,
                  :child_journey,
                  null: true,
                  foreign_key: { to_table: :journeys }
 end
end
