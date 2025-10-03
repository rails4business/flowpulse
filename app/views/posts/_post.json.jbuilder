json.extract! post, :id, :user_id, :title, :description, :cover_url, :video_url, :body, :published_at, :visibility, :state, :slug, :folder_path, :subdomain, :service_key, :position, :tags, :created_at, :updated_at
json.url post_url(post, format: :json)
