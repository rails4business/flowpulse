class CreateTaxbranches < ActiveRecord::Migration[8.0]
  def change
    create_table :taxbranches do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :description
      t.string :slug, null: false
      t.string :slug_category
      t.string :slug_label
      t.string :ancestry
      t.integer :position
      t.jsonb :meta

      t.timestamps
    end
     add_index :taxbranches, :slug, unique: true
     add_index :taxbranches, [ :slug_category, :slug_label, :slug ],
              unique: true,
              name: "index_taxbranches_on_cat_label_slug_unique"
  end
end
