class AddContentMdToPost < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :content_md, :text
  end
end
