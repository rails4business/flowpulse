class AddUniqueOpenActivityPerLeadTaxbranch < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :mode, :string
    add_column :activities, :channel, :string
    add_column :activities, :format, :string
    add_column :activities, :group_size, :integer
    add_column :activities, :location_type, :string
    add_column :activities, :location_name, :string
    add_column :activities, :location_address, :text
    add_column :activities, :center_taxbranch_id, :integer

    add_index :activities, :mode
    add_index :activities, :channel
    add_index :activities, :format
    add_index :activities, :location_type
    add_index :activities, :center_taxbranch_id
    add_foreign_key :activities, :taxbranches, column: :center_taxbranch_id



    add_index :activities,
              [ :lead_id, :taxbranch_id ],
              unique: true,
              where: "status IN ('recorded','reviewed')",
              name: "index_activities_unique_open_per_lead_taxbranch"
  end
end
