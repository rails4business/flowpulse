class RenameUrlMediaContetToUrlMediaContentInPosts < ActiveRecord::Migration[8.1]
  def change
        rename_column :posts, :url_media_contet, :url_media_content
  end
end
