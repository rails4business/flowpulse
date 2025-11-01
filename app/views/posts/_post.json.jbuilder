json.extract! post, :id, :user_id, :title, :slug, :description, :img_square_url, :img_vertical_url, :img_orizontal_url, :body, :published_at, :group_id, :group_type, :meta, :created_at, :updated_at
json.url post_url(post, format: :json)
json.body post.body.to_s
