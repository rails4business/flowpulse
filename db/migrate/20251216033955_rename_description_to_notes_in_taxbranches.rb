class RenameDescriptionToNotesInTaxbranches < ActiveRecord::Migration[8.1]
  def change
      rename_column :taxbranches, :description, :notes
  end
end
