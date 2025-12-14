class AddParentAndKindToEventdates < ActiveRecord::Migration[8.1]
  def change
   add_reference :eventdates, :parent_eventdate, foreign_key: { to_table: :eventdates }
    add_column :eventdates, :kind_event, :integer, default: 0, null: false
  end
end
