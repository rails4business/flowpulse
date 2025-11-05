class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :set_superadmin, except: %i[ index show  ]
  helper_method :sort_column, :sort_direction
  layout "application", except: %i[ index show  ]
  # GET /posts or /posts.json
  def index
  @taxbranches = Taxbranch.order(:slug_label)

  scope = Post.includes(:taxbranch, :lead)
  scope = scope.where(taxbranch_id: params[:taxbranch_id]) if params[:taxbranch_id].present?
  scope = scope.where(status: params[:status])             if params[:status].present?

  if params[:after].present?
    from = Time.zone.parse(params[:after]) rescue nil
    scope = scope.where("published_at >= ?", from) if from
  end
  if params[:before].present?
    to = Time.zone.parse(params[:before]) rescue nil
    scope = scope.where("published_at <= ?", to) if to
  end

  # ------ ORDINAMENTO SICURO (niente stringhe SQL interpolate) ------
  p  = Post.arel_table
  tb = Taxbranch.arel_table
  dir = (sort_direction == "asc" ? :asc : :desc)

  if sort_column == "tax"
    # COALESCE(taxbranches.slug_label, taxbranches.slug) con NULLS LAST senza stringhe
    coalesce = Arel::Nodes::NamedFunction.new("COALESCE", [ tb[:slug_label], tb[:slug] ])
    # Primo criterio: sposta i NULL in fondo → CASE WHEN COALESCE(...) IS NULL THEN 1 ELSE 0 END ASC
    nulls_last_flag = Arel::Nodes::Case.new(coalesce).when(nil).then(1).else(0)

    scope = scope.left_joins(:taxbranch)
                 .order(nulls_last_flag.asc)
                 .order(dir == :asc ? coalesce.asc : coalesce.desc)
  else
    # Mappa di colonne consentite
    allowed = {
      "title"        => p[:title],
      "status"       => p[:status],
      "published_at" => p[:published_at],
      "created_at"   => p[:created_at]
    }
    col = allowed[sort_column] || p[:published_at]
    scope = scope.order(dir == :asc ? col.asc : col.desc)
  end
  # ---------------------------------------------------------------

  scope = scope.order(id: :desc)
  @posts = scope.page(params[:page]).per(20)
end


  # GET /posts/1 or /posts/1.json
  def show
    @taxbranch = @post.taxbranch


    # 2️⃣ figli diretti da mostrare in home
    @children  = @taxbranch.children.ordered

    # 3️⃣ voci della navbar (solo figli con home_nav:true)
    @nav_items = @taxbranch.children.home_nav

    slug = @post.taxbranch&.slug_category&.parameterize&.underscore
    request.variant = slug.present? ? slug.to_sym : nil

    Rails.logger.info "🧩 Variant attiva: #{request.variant.inspect}"
  end

  # GET /posts/new
  def new
    @post = Current.user.lead.posts.build
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Current.user.lead.posts.build(post_params)
    @post.lead = Current.user.lead

    respond_to do |format|
      if @post.save
        format.html { redirect_to superadmin_taxbranch_path(@post.taxbranch), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to superadmin_taxbranch_path(@post.taxbranch), notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
   # Use callbacks to share common setup or constraints between actions.
   def set_post
    if params[:id].present?
      @post = Post.friendly.find(params[:id])
    elsif Current.respond_to?(:taxbranch) && Current.taxbranch.present?
      # se sei in sviluppo locale (localhost)
      if Rails.env.development? || request.host.include?("localhost")
        @post = Current.taxbranch.post || Post.first
      end
    else
      # fallback assoluto, utile se mancano entrambe le condizioni
      @post = Post.first
    end
  end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :lead_id, :title, :slug, :description, :thumb_url, :cover_url, :banner_url, :content, :published_at, :taxbranch_id, :status, :meta, :url_media_contet  ])
    end
    def sort_column
      case params[:sort]
      when "title"        then "title"
      when "status"       then "status"
      when "published_at" then "published_at"
      when "created_at"   then "created_at"
      when "tax"          then "tax"
      else "published_at"
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def set_superadmin
      redirect_to root_path, alert: "Accesso non autorizzato." unless Current.user&.superadmin?
    end
end
