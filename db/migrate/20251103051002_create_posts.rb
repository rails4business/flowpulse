class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :title
      t.string :slug
      t.text :description
      t.string :thumb_url
      t.string :cover_url
      t.string :banner_url
      t.text :content
      t.datetime :scheduled_at
      t.datetime :published_at
      t.integer :taxbranch_id
      t.integer :status, default: 0
      t.jsonb :meta, default: {}
      t.string :url_media_contet

      t.timestamps
    end
    add_index :posts, :taxbranch_id, unique: true
    add_index :posts, :slug, unique: true
    add_index :posts, :published_at
    add_index :posts, :meta, using: :gin
  end
end
