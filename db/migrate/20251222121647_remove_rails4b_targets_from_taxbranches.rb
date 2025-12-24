class RemoveRails4bTargetsFromTaxbranches < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :taxbranches, column: :rails4b_target_domain_id
    remove_index :taxbranches, :rails4b_target_domain_id
    remove_column :taxbranches, :rails4b_target_domain_id

    remove_foreign_key :taxbranches, column: :rails4b_target_service_id
    remove_index :taxbranches, :rails4b_target_service_id
    remove_column :taxbranches, :rails4b_target_service_id

    remove_foreign_key :taxbranches, column: :rails4b_target_journey_id
    remove_index :taxbranches, :rails4b_target_journey_id
    remove_column :taxbranches, :rails4b_target_journey_id

    remove_foreign_key :taxbranches, column: :generaimpresa_target_domain_id
    remove_index :taxbranches, :generaimpresa_target_domain_id
    remove_column :taxbranches, :generaimpresa_target_domain_id

    remove_foreign_key :taxbranches, column: :generaimpresa_target_service_id
    remove_index :taxbranches, :generaimpresa_target_service_id
    remove_column :taxbranches, :generaimpresa_target_service_id

    remove_foreign_key :taxbranches, column: :generaimpresa_target_journey_id
    remove_index :taxbranches, :generaimpresa_target_journey_id
    remove_column :taxbranches, :generaimpresa_target_journey_id

    remove_column :taxbranches, :branch_kind
  end
end
