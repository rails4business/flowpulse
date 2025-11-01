class CreateDomains < ActiveRecord::Migration[8.0]
  def change
    create_table :domains do |t|
      t.string :host
      t.string :language
      t.string :title
      t.text :description
      t.string :favicon_url
      t.string :square_logo_url
      t.string :horizontal_logo_url
      t.string :provider
      t.references :taxbranch, null: false, foreign_key: true

      t.timestamps
    end
    add_index :domains, :host, unique: true
  end
end
