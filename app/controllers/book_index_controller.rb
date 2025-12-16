class BookIndexController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    data = YAML.load_file(Rails.root.join("config/data/book_index.yml"))
    render json: data
  end
end
