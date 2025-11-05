# db/migrate/xxxx_create_tag_positionings.rb
class CreateTagPositionings < ActiveRecord::Migration[7.1]
  def change
    create_table :tag_positionings do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :taxbranch, null: false, foreign_key: true

      t.string :name,          null: false        # il “termine” (es. “dolori cervicali”)
      t.string :category,      null: false        # libera: “problema”, “target”, …
      t.jsonb  :metadata,      null: false, default: {}

      t.timestamps
    end

    add_index :tag_positionings, [ :taxbranch_id, :category ]
    add_index :tag_positionings, [ :taxbranch_id, :category, :name ], unique: true
    add_index :tag_positionings, :metadata, using: :gin
  end
end
