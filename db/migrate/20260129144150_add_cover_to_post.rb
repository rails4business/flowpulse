class AddCoverToPost < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :vertical_cover_url, :string
    add_column :posts, :horizontal_cover_url, :string
    remove_column :posts, :cover_url, :string
  end
end
