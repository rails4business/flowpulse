class AddAccessFlags < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :allows_invite,  :boolean, default: true, null: false
    add_column :services, :allows_request, :boolean, default: true, null: false

    add_column :journeys, :allows_invite,  :boolean
    add_column :journeys, :allows_request, :boolean

    add_column :eventdates, :allows_invite,  :boolean
    add_column :eventdates, :allows_request, :boolean
  end
end
