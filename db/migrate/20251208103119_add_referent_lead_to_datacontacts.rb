class AddReferentLeadToDatacontacts < ActiveRecord::Migration[8.1]
  def change
    add_column :datacontacts, :referent_lead_id, :integer
    add_column :datacontacts, :socials, :text
  end
end
