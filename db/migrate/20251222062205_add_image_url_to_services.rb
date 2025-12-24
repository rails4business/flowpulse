class AddImageUrlToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :image_url, :string
    add_column :services, :included_in_service_id, :integer
     add_column :services, :content_md, :text
    add_foreign_key :services, :services, column: :included_in_service_id
  end
end
