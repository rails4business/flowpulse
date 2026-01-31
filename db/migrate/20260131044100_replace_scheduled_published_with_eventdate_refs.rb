class ReplaceScheduledPublishedWithEventdateRefs < ActiveRecord::Migration[8.1]
  def change
    add_column :taxbranches, :scheduled_eventdate_id, :integer
    add_index  :taxbranches, :scheduled_eventdate_id
    remove_column :taxbranches, :scheduled_at, :datetime
  end
end
