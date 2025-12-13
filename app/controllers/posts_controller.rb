class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[show mark_done]

  before_action :set_post,         only: %i[edit update destroy]
  before_action :set_post_public,  only: %i[show mark_done]
  before_action :set_superadmin,   except: %i[show mark_done]

  helper_method :sort_column, :sort_direction

  layout "application", except: %i[show]

  # ----------------------------------------------------
  # MARK_DONE → registra l'evento di esercizio completato
  # ----------------------------------------------------
  def mark_done
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
    new_cycle  = last_event ? last_event.cycle + 1 : 1

    event = Eventdate.new(
      taxbranch:  taxbranch,
      lead:       lead,
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

  # ----------------
  # GET /posts (admin)
  # ----------------
  def index
    @taxbranches = Taxbranch.order(:slug_label)

    # base scope: includi taxbranch e lead, e fai join con taxbranch perché filtriamo/ordiniamo su di lui
    scope = Post.includes(:taxbranch, :lead).joins(:taxbranch)

    # filtro per taxbranch specifico
    scope = scope.where(taxbranch_id: params[:taxbranch_id]) if params[:taxbranch_id].present?

    # filtro per status EDITORIALE del taxbranch
    if params[:status].present? && Taxbranch.statuses.key?(params[:status])
      scope = scope.where(taxbranches: { status: Taxbranch.statuses[params[:status]] })
    end

    # filtro per published_at (sul taxbranch)
    if params[:after].present?
      from = Time.zone.parse(params[:after]) rescue nil
      scope = scope.where("taxbranches.published_at >= ?", from) if from
    end

    if params[:before].present?
      to = Time.zone.parse(params[:before]) rescue nil
      scope = scope.where("taxbranches.published_at <= ?", to) if to
    end

    # ------ ORDINAMENTO SICURO ------
    p  = Post.arel_table
    tb = Taxbranch.arel_table
    dir = (sort_direction == "asc" ? :asc : :desc)

    if sort_column == "tax"
      coalesce = Arel::Nodes::NamedFunction.new("COALESCE", [ tb[:slug_label], tb[:slug] ])
      nulls_last_flag = Arel::Nodes::Case.new(coalesce).when(nil).then(1).else(0)

      scope = scope
        .order(nulls_last_flag.asc)
        .order(dir == :asc ? coalesce.asc : coalesce.desc)
    else
      allowed = {
        "title"        => p[:title],
        "status"       => tb[:status],        # ora status è sul taxbranch
        "published_at" => tb[:published_at],  # idem published_at
        "created_at"   => p[:created_at]
      }
      col = allowed[sort_column] || tb[:published_at]
      scope = scope.order(dir == :asc ? col.asc : col.desc)
    end

    scope  = scope.order(id: :desc)
    @posts = scope.page(params[:page]).per(20)
  end

  # ------------------------
  # GET /posts/:id (pubblico)
  # ------------------------
  def show
    @taxbranch      = @post.taxbranch
    @taxbranch_node = @post.taxbranch

    @children  = @taxbranch.children.ordered
    @nav_items = @taxbranch.children.home_nav

    slug = @post.taxbranch&.slug_category&.parameterize&.underscore
    request.variant = slug.present? ? slug.to_sym : nil

    Rails.logger.info "🧩 Variant attiva: #{request.variant.inspect}"
  end

  # GET /posts/new
  def new
    @post = Current.user.lead.posts.build
  end

  # GET /posts/:id/edit
  def edit
  end

  # POST /posts
  def create
    @post = Current.user.lead.posts.build(post_params)

    if @post.save
      redirect_to [ :superadmin, @post.taxbranch ], notice: "Post creato.", status: :see_other
    else
      @taxbranch = @post.taxbranch
      @children  = @taxbranch.children.ordered.includes(:domains)
      render "superadmin/taxbranches/show", status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      redirect_to [ :superadmin, @post.taxbranch ], notice: "Post aggiornato.", status: :see_other
    else
      @taxbranch = @post.taxbranch
      @children  = @taxbranch.children.ordered.includes(:domains)
      render "superadmin/taxbranches/show", status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    tb = @post.taxbranch
    @post.destroy!
    redirect_to [ :superadmin, tb ], notice: "Post eliminato.", status: :see_other
  end

  private

  # Solo per edit/update/destroy
  def set_post
    return unless params[:id].present?
    @post = Post.includes(:taxbranch).friendly.find(params[:id])
  end

  # 🔓 Scelta del post "pubblico" per show/mark_done

  def set_post_public
  # 1️⃣ Se c'è un id esplicito → usa solo FriendlyId + controlli editoriali
  if params[:id].present?
    @post = Post.includes(:taxbranch).friendly.find(params[:id])

    unless post_published_for_public?(@post)
      redirect_to root_path, alert: "Il post non è pubblicato." and return
    end

    @taxbranch = @post.taxbranch
    return
  end

  # 2️⃣ Nessun id: prova col taxbranch del dominio corrente
  domain_taxbranch = Current.domain&.taxbranch

  if domain_taxbranch
    @taxbranch = domain_taxbranch
    @post      = domain_taxbranch.post

    # Se il post non esiste o non è pubblicabile, prova sui figli visibili
    unless @post && post_published_for_public?(@post)
      visible_children_ids = domain_taxbranch.children
                                             .where(
                                               status:     Taxbranch.statuses[:published],
                                               visibility: Taxbranch.visibilities[:public_node]
                                             )
                                             .pluck(:id)

      @post = Post.joins(:taxbranch)
                  .where(taxbranches: { id: visible_children_ids })
                  .first
    end
  end

# 3️⃣ Fallback globale: qualsiasi post pubblicabile
# 3️⃣ Fallback globale: qualsiasi post pubblicabile
@post ||= Post.joins(:taxbranch)
              .where(
                taxbranches: {
                  status:     Taxbranch.statuses[:published],
                  visibility: Taxbranch.visibilities[:public_node]
                }
              )
              .where("taxbranches.published_at IS NULL OR taxbranches.published_at <= ?", Time.current)
              .order(
                Arel.sql("COALESCE(taxbranches.published_at, taxbranches.created_at) DESC")
              )
              .first


  if @post.nil?
    redirect_to posts_path, alert: "Nessun post pubblicato disponibile." and return
  end

  @taxbranch ||= @post.taxbranch
end

  # Logica di visibilità: usa LO STATO DEL TAXBRANCH (non più quello del post)
  def post_published_for_public?(post)
    tb = post.taxbranch
    return false unless tb

    # stato editoriale
    return false unless tb.published?
    # visibilità
    return false unless tb.public_node?
    # data di pubblicazione (se c'è)
    return false if tb.published_at.present? && tb.published_at > Time.current

    true
  end

  def post_params
    # niente più :status e :published_at qui, perché vivono su Taxbranch
    params.expect(post: [
      :lead_id,
      :title,
      :slug,
      :description,
      :thumb_url,
      :cover_url,
      :banner_url,
      :content,
      :content_md,
      :taxbranch_id,
      :mermaid,
      :meta,
      :url_media_content
    ])
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
