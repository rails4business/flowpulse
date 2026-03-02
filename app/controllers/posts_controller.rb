class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[show mark_done pricing]

  before_action :set_post,         only: %i[edit update destroy]
  before_action :set_post_public,  only: %i[show mark_done pricing submit_questionnaire]
  before_action :set_superadmin,   except: %i[show mark_done pricing]

  helper_method :sort_column, :sort_direction

  layout "application", except: %i[show pricing]

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
      begin
        lead.activities.create!(
          domain: Current.domain,
          taxbranch: taxbranch,
          eventdate: event,
          kind: "step_completed",
          status: "recorded",
          occurred_at: event.date_start || Time.current,
          source: "post_mark_done",
          source_ref: @post&.slug.presence || taxbranch.slug
        )
      rescue StandardError => e
        Rails.logger.warn("Activity non salvata in mark_done: #{e.class} - #{e.message}")
      end

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
    request.variant =
      if @taxbranch&.questionnaire_source_path.present? || @taxbranch&.questionnaire_root?
        :questionnaire
      else
        slug.present? ? slug.to_sym : nil
      end
    load_questionnaire_for_show if request.variant == :questionnaire

    Rails.logger.info "🧩 Variant attiva: #{request.variant.inspect}"
  end

  # -----------------------------
  # GET /posts/:id/pricing (pubblico)
  # -----------------------------
  def pricing
    @taxbranch      = @post.taxbranch
    @taxbranch_node = @post.taxbranch
    @services       = Array(@taxbranch&.service).compact

    slug = @taxbranch&.slug_category&.parameterize&.underscore
    request.variant = slug.present? ? slug.to_sym : nil

    Rails.logger.info "🧩 Variant attiva (pricing): #{request.variant.inspect}"
  end

  def submit_questionnaire
    lead = Current.user&.lead
    unless lead
      redirect_to login_path, alert: "Devi essere autenticato per inviare il questionario."
      return
    end

    questionnaire_taxbranch = @post.taxbranch
    has_yaml_questionnaire = questionnaire_taxbranch&.questionnaire_source_path.present?
    unless questionnaire_taxbranch&.questionnaire_root? || has_yaml_questionnaire
      redirect_to post_path(@post), alert: "Questo post non e un questionario."
      return
    end

    answers = submitted_questionnaire_answers
    if answers.blank?
      redirect_to post_path(@post, q: params[:q].presence || 1), alert: "Seleziona almeno una risposta prima di inviare."
      return
    end

    activity = QuestionnaireSubmission.call(
      lead: lead,
      questionnaire_taxbranch: questionnaire_taxbranch,
      answers: answers,
      occurred_at: Time.current,
      description: "Questionario inviato da #{lead.full_name.presence || lead.username.presence || "lead##{lead.id}"}",
      source_ref: @post.slug
    )

    redirect_to post_path(@post, q: params[:q].presence || 1), notice: "Questionario salvato. Risultato: #{activity.level_code.presence || 'n/d'} (#{activity.score_total || 0}/#{activity.score_max || 0})."
  rescue QuestionnaireSubmission::Error => e
    redirect_to post_path(@post, q: params[:q].presence || 1), alert: e.message
  end

  # GET /posts/new
  def new
    @post = Current.user.lead.posts.build
    taxbranch_id = params.dig(:post, :taxbranch_id).presence || params[:taxbranch_id].presence
    @post.taxbranch_id = taxbranch_id if taxbranch_id.present?
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
      @taxbranch = @post.taxbranch || Taxbranch.find_by(id: params.dig(:post, :taxbranch_id))
      if @taxbranch.present?
        @children  = @taxbranch.children.ordered.includes(:domains)
        render "superadmin/taxbranches/show", status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      redirect_to [ :superadmin, @post.taxbranch ], notice: "Post aggiornato.", status: :see_other
    else
      @taxbranch = @post.taxbranch || Taxbranch.find_by(id: params.dig(:post, :taxbranch_id))
      if @taxbranch.present?
        @children  = @taxbranch.children.ordered.includes(:domains)
        render "superadmin/taxbranches/show", status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
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

  def load_questionnaire_for_show
    @questionnaire_source = @taxbranch.questionnaire_source
    @questionnaire_version = @taxbranch.questionnaire_version
    @questionnaire_data = @taxbranch.questionnaire_definition
    fallback = nil

    if extract_questionnaire_questions(@questionnaire_data).blank?
      fallback = load_questionnaire_fallback_data
      if fallback.present?
        @questionnaire_data = fallback[:data]
        @questionnaire_source = fallback[:source].to_s.presence || @questionnaire_source
        @questionnaire_version = fallback[:version].to_s.presence || @questionnaire_version
        sync_questionnaire_meta_from_fallback!(fallback)
      end
    end

    raw_questions = extract_questionnaire_questions(@questionnaire_data)
    @questionnaire_questions = Array(raw_questions).sort_by { |q| q["position"].to_i }
    raw_scoring = questionnaire_hash_value(@questionnaire_data, "scoring")
    @questionnaire_scoring = raw_scoring.is_a?(Hash) ? raw_scoring : {}
    @questionnaire_debug = {
      source: @questionnaire_source.presence || "(vuoto)",
      file_exists: questionnaire_source_file_exists?(@questionnaire_source),
      top_level_keys: @questionnaire_data.is_a?(Hash) ? @questionnaire_data.keys : [],
      questions_count: @questionnaire_questions.size,
      fallback_used: fallback.present?
    }
  end

  def questionnaire_source_file_exists?(source)
    normalized = source.to_s.sub(%r{\A/+}, "")
    return false if normalized.blank?
    return false unless normalized.start_with?("config/data/questionnaires/")
    return false unless normalized.match?(/\.ya?ml\z/i)

    File.exist?(Rails.root.join(normalized))
  end

  def load_questionnaire_fallback_data
    files = Dir.glob(Rails.root.join("config/data/questionnaires/*.{yml,yaml}")).sort
    return nil if files.empty?

    candidates = []
    tokens = [
      @taxbranch.slug.to_s.split("/").last,
      @taxbranch.slug_label.to_s,
      @post.slug.to_s
    ].map { |v| normalize_questionnaire_token(v) }.reject(&:blank?).uniq

    files.each do |path|
      begin
        data = YAML.safe_load_file(path, permitted_classes: [], aliases: false) || {}
      rescue Psych::Exception
        next
      end
      next unless data.is_a?(Hash)

      questions = Array(data["questions"] || data["domande"])
      next if questions.blank?

      basename = File.basename(path, ".*")
      slug_token = normalize_questionnaire_token(data["slug"])
      title_token = normalize_questionnaire_token(data["title"])
      file_token = normalize_questionnaire_token(basename)
      match_score = tokens.sum do |t|
        [
          (slug_token == t ? 3 : 0),
          (file_token == t ? 2 : 0),
          (title_token == t ? 1 : 0),
          (slug_token.include?(t) || t.include?(slug_token) ? 1 : 0),
          (file_token.include?(t) || t.include?(file_token) ? 1 : 0)
        ].max
      end

      candidates << { path: path, data: data, score: match_score }
    end

    chosen =
      if candidates.size == 1
        candidates.first
      else
        candidates.sort_by { |row| [-row[:score], row[:path]] }.first
      end
    return nil if chosen.blank?

    rel = Pathname.new(chosen[:path]).relative_path_from(Rails.root).to_s
    {
      source: rel,
      path: chosen[:path],
      data: chosen[:data],
      version: chosen[:data]["version"].to_s.presence
    }
  end

  def normalize_questionnaire_token(value)
    value.to_s.downcase
      .tr("àèéìíîòóùú", "aeeiiioouu")
      .gsub(/[^a-z0-9]+/, "_")
      .gsub(/\A_+|_+\z/, "")
  end

  def extract_questionnaire_questions(data)
    return [] unless data.is_a?(Hash)

    value = questionnaire_hash_value(data, "questions")
    value = questionnaire_hash_value(data, "domande") if value.blank?
    Array(value)
  end

  def questionnaire_hash_value(hash, key)
    return nil unless hash.is_a?(Hash)

    hash[key] || hash[key.to_sym]
  end

  def submitted_questionnaire_answers
    raw = params[:answers]
    parsed = case raw
    when ActionController::Parameters
      raw.to_unsafe_h
    when Hash
      raw
    else
      {}
    end

    parsed.to_h.each_with_object({}) do |(key, value), memo|
      next if key.to_s.strip.blank?
      next if value.to_s.strip.blank?

      memo[key.to_s] = value
    end
  end

  def sync_questionnaire_meta_from_fallback!(fallback)
    return if fallback.blank?
    return unless @taxbranch&.slug_category.to_s == "questionnaire"

    source = fallback[:source].to_s.strip
    version = fallback[:version].to_s.strip
    return if source.blank?

    meta_hash = @taxbranch.meta.is_a?(Hash) ? @taxbranch.meta.deep_dup : {}
    changed = false

    if meta_hash["questionnaire_source"].to_s != source
      meta_hash["questionnaire_source"] = source
      changed = true
    end

    if version.present? && meta_hash["questionnaire_version"].to_s != version
      meta_hash["questionnaire_version"] = version
      changed = true
    end

    return unless changed

    @taxbranch.update_columns(meta: meta_hash, updated_at: Time.current)
    @taxbranch.meta = meta_hash
  rescue StandardError => e
    Rails.logger.warn("Questionnaire fallback sync skipped for taxbranch ##{@taxbranch&.id}: #{e.class} #{e.message}")
  end

  def post_params
    # niente più :status e :published_at qui, perché vivono su Taxbranch
    params.expect(post: [
      :lead_id,
      :title,
      :slug,
      :description,
      :thumb_url,
      :horizontal_cover_url,
      :vertical_cover_url,
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
