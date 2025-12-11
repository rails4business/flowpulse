class RemoveCycleFromEventdates < ActiveRecord::Migration[8.1]
  def change
    remove_column :eventdates, :cycle, :integer
  end
end
