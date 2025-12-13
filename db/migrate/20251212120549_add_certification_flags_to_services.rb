class AddCertificationFlagsToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :auto_certificate, :boolean
    add_column :services, :require_booking_verification, :boolean
    add_column :services, :require_enrollment_verification, :boolean
    add_column :services, :verifier_roles, :jsonb
   end
end
