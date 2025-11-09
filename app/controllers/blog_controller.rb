# app/controllers/blog_controller.rb
class BlogController < ApplicationController
  def index
    # 1️⃣ Prendi il dominio corrente
    domain = Current.domain

    # 2️⃣ Se non c'è dominio o taxbranch associato → redirect alla home pubblica
    unless domain&.taxbranch
      return redirect_to root_path, alert: "Blog non disponibile per questo dominio."
    end

    # 3️⃣ Trova il ramo 'blog' tra i figli del taxbranch principale
    @blog_branch = domain.taxbranch.children.find_by(slug: "blog")

    # 4️⃣ Se non trovato → redirect
    unless @blog_branch
      return redirect_to root_path, alert: "Blog non disponibile per questo dominio."
    end

    # 5️⃣ Carica i post se tutto ok
    @posts = @blog_branch.posts
                         .where(status: :published)
                         .order(published_at: :desc)
                         .page(params[:page]).per(12)
  end

  def show
    @post = Post.find_by!(slug: params[:id])
  end
end
