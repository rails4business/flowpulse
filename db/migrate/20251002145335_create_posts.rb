class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true   # 👈 collegamento autore
      t.string   :title,        null: false
      t.text     :description
      t.string   :cover_url
      t.string   :video_url
      t.text     :body
      t.datetime :published_at
      t.integer  :visibility,   null: false, default: 0
      t.integer  :state,        null: false, default: 0
      t.string   :slug,         null: false
      t.string   :domains,      array: true, default: []   # 👈 aggiunto a mano
      t.string   :folder_path
      t.string   :subdomain
      t.string   :service_key,  null: false, default: "blog"
      t.integer  :position
      t.string   :tags,         array: true, default: []   # 👈 aggiunto a mano

      t.timestamps
    end

    add_index :posts, :slug, unique: true
    add_index :posts, :published_at
    add_index :posts, [ :subdomain, :service_key ]
    add_index :posts, :folder_path
    add_index :posts, :tags, using: :gin
    add_index :posts, :domains, using: :gin
  end
end
