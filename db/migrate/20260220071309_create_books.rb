class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
# dentro create_table :books do |t|
t.string  :slug
t.string  :title
t.string  :subtitle
t.string  :author
t.text    :description

t.string  :folder_md
t.string  :index_file

t.decimal :price_euro, precision: 10, scale: 2
t.decimal :price_dash, precision: 16, scale: 8

t.integer :access_mode
t.boolean :active

t.text    :url_cover_front
t.text    :url_cover_back

t.date    :published_at
t.string  :isbn
t.string  :language
t.integer :pages_count
t.integer :sort_position




      t.timestamps
    end
  end
end
