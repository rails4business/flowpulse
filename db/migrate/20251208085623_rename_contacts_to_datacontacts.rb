class RenameContactsToDatacontacts < ActiveRecord::Migration[8.1]
  def change
    rename_table :contacts, :datacontacts
  end
end
