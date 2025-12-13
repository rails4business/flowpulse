class AddRolesToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :participant_role, :string
    add_column :enrollments, :target_role, :string
    add_column :enrollments, :certified_at, :datetime
  end
end
