class CreateBookDomains < ActiveRecord::Migration[8.1]
  def change
    create_table :book_domains do |t|
      t.references :book, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true

      t.timestamps
    end
  end
end
