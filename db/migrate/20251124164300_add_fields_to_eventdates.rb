class AddFieldsToEventdates < ActiveRecord::Migration[8.1]
  def change
    add_reference :eventdates, :journey, foreign_key: true, null: true
    add_column    :eventdates, :event_type,      :integer, default: 0, null: false
    add_column    :eventdates, :mode,            :integer, default: 0, null: false
    add_column    :eventdates, :max_participants, :integer
    add_column    :eventdates, :location,        :string
    add_column    :eventdates, :visibility,      :integer, default: 0, null: false
    change_column_null :eventdates, :taxbranch_id, true
  end
end
