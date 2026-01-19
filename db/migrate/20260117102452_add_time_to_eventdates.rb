class AddTimeToEventdates < ActiveRecord::Migration[8.1]
  def change
    add_column :eventdates, :time_duration, :integer
    add_column :eventdates, :unit_duration, :integer
    add_column :eventdates, :position, :integer
  end
end
