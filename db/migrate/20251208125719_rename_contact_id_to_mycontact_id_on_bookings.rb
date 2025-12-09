class RenameContactIdToMycontactIdOnBookings < ActiveRecord::Migration[8.1]
  def change
    rename_column :bookings, :contact_id, :mycontact_id
  end
end
