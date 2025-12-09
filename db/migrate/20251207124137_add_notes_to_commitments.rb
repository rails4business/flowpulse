class AddNotesToCommitments < ActiveRecord::Migration[8.1]
  def change
    add_column :commitments, :notes, :text
  end
end
