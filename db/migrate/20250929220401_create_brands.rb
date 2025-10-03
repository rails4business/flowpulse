class CreateBrands < ActiveRecord::Migration[8.0]
  def change
    create_table :brands do |t|
      t.string  :host,            null: false
      t.string  :controller_slug, null: false
      t.jsonb   :aliases,         null: false, default: []
      t.text    :description
      t.string  :url_landing
      t.string  :favicon_url
      t.string  :category
      t.boolean :show_in_home,    null: false, default: true
      t.jsonb   :seo,             null: false, default: {}
      t.text    :pages,           array: true, default: []
      t.timestamps
    end
    add_index :brands, :host, unique: true
  end
end
