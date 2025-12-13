class AddRails4bToTaxbranch < ActiveRecord::Migration[8.1]
 def change
    add_column :taxbranches, :branch_kind, :integer, default: 1, null: false

    add_column :taxbranches, :rails4b_target_domain_id,  :integer
    add_index  :taxbranches, :rails4b_target_domain_id
    add_foreign_key :taxbranches, :domains,  column: :rails4b_target_domain_id

    add_column :taxbranches, :rails4b_target_service_id, :integer
    add_index  :taxbranches, :rails4b_target_service_id
    add_foreign_key :taxbranches, :services, column: :rails4b_target_service_id

    add_column :taxbranches, :rails4b_target_journey_id, :integer
    add_index  :taxbranches, :rails4b_target_journey_id
    add_foreign_key :taxbranches, :journeys, column: :rails4b_target_journey_id

    add_column :taxbranches, :generaimpresa_target_domain_id,  :integer
    add_index  :taxbranches, :generaimpresa_target_domain_id
    add_foreign_key :taxbranches, :domains,  column: :generaimpresa_target_domain_id

    add_column :taxbranches, :generaimpresa_target_service_id, :integer
    add_index  :taxbranches, :generaimpresa_target_service_id
    add_foreign_key :taxbranches, :services, column: :generaimpresa_target_service_id

    add_column :taxbranches, :generaimpresa_target_journey_id, :integer
    add_index  :taxbranches, :generaimpresa_target_journey_id
    add_foreign_key :taxbranches, :journeys, column: :generaimpresa_target_journey_id
  end
end
