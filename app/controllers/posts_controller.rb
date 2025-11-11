class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[  show ]
  before_action :set_post, only: %i[  edit update destroy index]
  before_action :set_post_public,  only: %i[  show mark_done]
  before_action :set_superadmin, except: [ :show, :mark_done ]
  helper_method :sort_column, :sort_direction
  layout "application", except: %i[  show  ]
# GET /posts or /posts.json
# app/controllers/posts_controller.rb
def mark_done
  # Lead corrente
  lead = Current.user&.lead || (defined?(current_lead) ? current_lead : nil)
  unless lead
    redirect_back fallback_location: post_path(params[:id]), alert: "Devi essere autenticato per registrare l'esercizio."
    return
  end

  taxbranch = Taxbranch.find_by(id: params[:taxbranch_id])
  unless taxbranch
    redirect_back fallback_location: post_path(params[:id]), alert: "Impossibile trovare l'esercizio da marcare."
    return
  end

  last_event = Eventdate.where(lead: lead, taxbranch: taxbranch).order(cycle: :desc).first
  new_cycle = last_event ? last_event.cycle + 1 : 1

  event = Eventdate.new(
    taxbranch: taxbranch,
    lead:      lead,
    date_start: Time.current,
    date_end:   Time.current,
    cycle:      new_cycle,
    status:     :completed # enum
  )

  if event.save
    redirect_back fallback_location: post_path(params[:id]),
                  notice: "🎉 Esercizio “#{taxbranch.post&.title || 'senza titolo'}” completato (ciclo #{new_cycle})."
  else
    redirect_back fallback_location: post_path(params[:id]),
                  alert: "Errore nel salvataggio: #{event.errors.full_messages.to_sentence}"
  end
rescue => e
  Rails.logger.error "Errore in mark_done: #{e.message}"
  redirect_back fallback_location: post_path(params[:id]),
                alert: "Si è verificato un errore inatteso."
end


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
    @taxbranch_node  = @post.taxbranch

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

  def create
    @post = Current.user.lead.posts.build(post_params)

    if @post.save
      redirect_to [ :superadmin, @post.taxbranch ], notice: "Post creato.", status: :see_other
    else
      # Rendi di nuovo la show del taxbranch con il form e gli errori
      @taxbranch = @post.taxbranch
      @children  = @taxbranch.children.ordered.includes(:domains)
      render "superadmin/taxbranches/show", status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to [ :superadmin, @post.taxbranch ], notice: "Post aggiornato.", status: :see_other
    else
      @taxbranch = @post.taxbranch
      @children  = @taxbranch.children.ordered.includes(:domains)
      render "superadmin/taxbranches/show", status: :unprocessable_entity
    end
  end


  # DELETE /posts/1 or /posts/1.json
  def destroy
      tb = @post.taxbranch
      @post.destroy!
      redirect_to [ :superadmin, tb ], notice: "Post eliminato.", status: :see_other
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
    return unless params[:id].present?
    @post = Post.friendly.find(params[:id])
  end

  def set_post_public
      # 1) Se arriva un ID esplicito → carichiamo solo se pubblicato
      if params[:id].present?
        @post = Post.friendly.find(params[:id])
        unless @post&.published_at.present? || @post&.status == "published"
          redirect_to posts_path, alert: "Il post non è pubblicato." and return
        end
        return
      end

      # 2) Nessun ID: usa il post del taxbranch del dominio (solo se pubblicato)
      tb = Current.respond_to?(:taxbranch) ? Current.taxbranch : nil

      if tb
        # post "di casa" del taxbranch corrente
        if tb.post&.published_at.present? || tb.post&.status == "published"
          @post = tb.post
        else
          # primo pubblicato tra i figli (il più recente)
          @post = tb.children
                    .joins(:post)
                    .merge(Post.where.not(published_at: nil))
                    .order("posts.published_at DESC")
                    .first&.post
        end
      end

      # 3) Fallback di sito: ultimo pubblicato globale (se proprio non c’è nulla nel ramo)
      @post ||= Post.where.not(published_at: nil).order(published_at: :desc).first

      # 4) Se ancora nil → nessun pubblicato
      if @post.nil?
        redirect_to posts_path, alert: "Nessun post pubblicato disponibile." and return
      end
    end



    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :lead_id, :title, :slug, :description, :thumb_url, :cover_url, :banner_url, :content, :content_md, :published_at, :taxbranch_id, :status, :meta, :url_media_content  ])
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
