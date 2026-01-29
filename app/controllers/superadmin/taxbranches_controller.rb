module Superadmin
  class TaxbranchesController < ApplicationController
    include RequireSuperadmin
    require "csv"
    layout "generaimpresa_taxbranch", only: %i[generaimpresa]

    before_action :set_taxbranch, only: %i[
      show edit update destroy journeys positioning set_link_child
      move_down move_up move_right move_left
      generaimpresa post export_import export import rails4b
    ]
    before_action :load_domains, only: %i[new edit create update]
    before_action :load_services_and_journeys, only: %i[new edit create update]

  # GET /taxbranches or /taxbranches.json
  def index
    # 1. Scope di base in base all'utente
    base_scope =
      if Current.user&.superadmin?
        Taxbranch.all
      else
        Current.user&.lead&.taxbranches || Taxbranch.none
      end

    # 2. Modalità: selezione link vs elenco normale
    @link_parent = nil

    if params[:link_parent_id].present?
      @link_parent_id = params[:link_parent_id].to_i
      @link_parent   = Taxbranch.find_by(id: @link_parent_id)

      # in modalità selezione link: di solito vuoi vedere TUTTI (o quasi)
      scope = base_scope
    else
      # elenco normale: solo radici
      scope = base_scope.where(ancestry: [ nil, "" ])
    end

    # 3. Ricerca testuale (slug, label, category)
    if params[:q].present?
      q = "%#{params[:q].strip}%"
      scope = scope.where(
        "slug ILIKE :q OR slug_label ILIKE :q OR slug_category ILIKE :q",
        q: q
      )
    end

    # 4. Ordinamento finale
    @taxbranches = scope.ordered
  end

  def journeys
    @journeys = @taxbranch.journeys
  end

   def set_link_child
    child  = Taxbranch.find(params[:id])               # quello cliccato in index
    parent = Taxbranch.find(params[:link_parent_id])   # quello da trasformare in link

    if parent.children.any?
      redirect_to superadmin_taxbranch_path(parent),
                  alert: "Questo taxbranch ha figli: non può essere trasformato in link."
      return
    end

    parent.update!(link_child: child)

    redirect_to superadmin_taxbranch_path(parent),
                notice: "Collegato a «#{child.display_label}»."
  end
  # GET /taxbranches/1 or /taxbranches/1.json
  def show
     @taxbranch_node = @taxbranch
     @children = @taxbranch.children.ordered


      @post   = @taxbranch.post || @taxbranch.build_post(lead: Current.user&.lead)
  end

  # GET /taxbranches/new
  def new
    @taxbranch = Current.user.lead.taxbranches.build(
      status:     :draft,
      visibility: :private_node
    )

    if params[:parent_id]
      @taxbranch.parent_id = params[:parent_id] if params[:parent_id].present?
    end
  end


  # GET /taxbranches/1/edit
  def edit
  end


  # POST /taxbranches or /taxbranches.json
  def create
    scope = Current.user.lead.taxbranches
    @taxbranch = scope.build(taxbranch_params)

    # fallback dal query string se non inviato nel form
    @taxbranch.parent_id ||= params[:parent_id].presence


    Taxbranch.transaction do
      @taxbranch.save!
    end

    redirect_target = @taxbranch.parent_id.present? ? superadmin_taxbranch_path(@taxbranch.parent_id) : superadmin_taxbranch_path(@taxbranch)
    redirect_to(redirect_target, notice: "Creato.", status: :see_other)
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end


def update
  if @taxbranch.update(taxbranch_params)
    redirect_target = @taxbranch.parent_id.present? ? superadmin_taxbranch_path(@taxbranch.parent_id) : superadmin_taxbranch_path(@taxbranch)
    redirect_to(redirect_target, notice: "Taxbranch aggiornata.", status: :see_other) # 303
  else
    render :edit, status: :unprocessable_entity
  end
end

  # DELETE /taxbranches/1 or /taxbranches/1.json
  def destroy
    @taxbranch.destroy!

    respond_to do |format|
      format.html { redirect_to superadmin_taxbranches_path, notice: "Taxbranch was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end
  def move_up
    @taxbranch.move_higher
    redirect_back fallback_location: superadmin_taxbranches_path
  end

  def move_down
    @taxbranch.move_lower
    redirect_back fallback_location: superadmin_taxbranches_path
  end

  def move_left
    parent = @taxbranch.parent
    if parent&.parent.present?
      @taxbranch.update(parent: parent.parent)
    else
      @taxbranch.update(parent: nil)
    end
    redirect_back fallback_location: superadmin_taxbranches_path
  end

  def move_right
    previous = @taxbranch.higher_item
    if previous.present?
      @taxbranch.update(parent: previous)
    end
    redirect_back fallback_location: superadmin_taxbranches_path
  end

  def positioning
    @taxbranch_node = @taxbranch
    rows = @taxbranch.tag_positionings
    counts = rows.group(:name, :category).count
    @items = counts.map { |(name, cat), n| { text: name, count: n, cat: cat } }
       @tags_by_category = @taxbranch.tag_positionings.order(:category, :name).group_by(&:category)
  end

  def generaimpresa
    @domain = @taxbranch.header_domain
    root = @taxbranch
    subtree = @taxbranch.subtree
    current_tab = params[:tab].presence || "generaimpresa"
    @graph_root_id = @taxbranch.id

    @graph_nodes = subtree.map do |tb|
      full_label = tb.display_label.to_s
      short_label = full_label.length > 18 ? "#{full_label[0, 18]}…" : full_label
      {
        id: tb.id,
        label: short_label,
        title: full_label,
        url: generaimpresa_superadmin_taxbranch_path(tb, tab: current_tab)
      }
    end
    @graph_edges = subtree.filter_map do |tb|
      next unless tb.parent_id

      { from: tb.parent_id, to: tb.id }
    end
  end

  def rails4b
    load_rails4b_data
    render :rails4b, layout: "generaimpresa_taxbranch"
  end

  def post
    @post = @taxbranch.post || @taxbranch.build_post(lead: Current.user&.lead)
  end

  def export_import
    @default_lead_id = Current.user&.lead_id
  end

  def export
    subtree = @taxbranch.subtree.order(:ancestry, :position, :slug_label)

    csv = CSV.generate(headers: true) do |out|
      out << %w[
        slug slug_category slug_label parent_slug lead_id visibility status position home_nav
        post_title post_content_md post_content post_slug post_lead_id
      ]
      subtree.each do |tb|
        post = tb.post
        out << [
          tb.slug,
          tb.slug_category,
          tb.slug_label,
          tb.parent&.slug,
          tb.lead_id,
          tb.visibility,
          tb.status,
          tb.position,
          tb.home_nav,
          post&.title,
          post&.content_md,
          post&.content,
          post&.slug,
          post&.lead_id
        ]
      end
    end

    filename = "taxbranches_subtree_#{@taxbranch.id}_#{Time.zone.now.strftime('%Y%m%d_%H%M')}.csv"
    send_data csv, filename: filename, type: "text/csv"
  end

  def import
    file = params[:file]
    duplicate_mode = params[:duplicate_mode].presence || "skip"
    lead_id_default = params[:lead_id].presence || Current.user&.lead_id

    unless file
      redirect_to export_import_superadmin_taxbranch_path(@taxbranch), alert: "Seleziona un file CSV."
      return
    end

    rows = CSV.parse(file.read, headers: true)
    results = { created: 0, updated: 0, skipped: 0, errors: [] }
    post_results = { created: 0, updated: 0, skipped: 0 }
    imported = []
    slug_map = {}

    Taxbranch.transaction do
      rows.each_with_index do |row, idx|
        slug = row["slug"].to_s.strip
        if slug.blank?
          results[:errors] << "Riga #{idx + 2}: slug mancante."
          next
        end

        tb = Taxbranch.find_by(slug: slug)
        attrs = {
          slug: slug,
          slug_category: row["slug_category"].presence,
          slug_label: row["slug_label"].presence,
          lead_id: row["lead_id"].presence || lead_id_default,
          visibility: row["visibility"].presence,
          status: row["status"].presence,
          home_nav: parse_bool(row["home_nav"])
        }.compact

        if tb
          case duplicate_mode
          when "skip"
            results[:skipped] += 1
            slug_map[slug] = tb.id
            next
          when "error"
            results[:errors] << "Riga #{idx + 2}: slug già esistente (#{slug})."
            next
          else
            tb.assign_attributes(attrs.except(:slug))
            tb.save!
            results[:updated] += 1
          end
        else
          tb = Taxbranch.new(attrs)
          tb.save!
          results[:created] += 1
        end

        slug_map[slug] = tb.id
        imported << {
          tb: tb,
          parent_slug: row["parent_slug"].to_s.strip.presence,
          row_index: idx,
          position: row["position"].to_s.strip,
          post_data: {
            title: row["post_title"].presence,
            content_md: row["post_content_md"].presence,
            content: row["post_content"].presence,
            slug: row["post_slug"].presence,
            lead_id: row["post_lead_id"].presence || lead_id_default || tb.lead_id
          }
        }
      end

      imported.each do |item|
        tb = item[:tb]
        parent_slug = item[:parent_slug]

        parent_id =
          if parent_slug.present?
            slug_map[parent_slug]
          else
            @taxbranch.id
          end

        if parent_id.nil?
          results[:errors] << "Slug parent non trovato per #{tb.slug} (#{parent_slug})."
          next
        end

        tb.update!(parent_id: parent_id)
      end

      groups = imported.group_by { |i| i[:tb].parent_id }
      groups.each_value do |items|
        ordered = items.sort_by do |i|
          pos = i[:position].to_i
          pos.positive? ? pos : (i[:row_index] + 1)
        end
        ordered.each_with_index do |i, index|
          i[:tb].insert_at(index + 1)
        end
      end

      imported.each do |item|
        tb = item[:tb]
        post_data = item[:post_data]
        next unless post_data.values.any?(&:present?)

        post = tb.post
        if post
          case duplicate_mode
          when "skip"
            post_results[:skipped] += 1
            next
          when "error"
            results[:errors] << "Post già esistente per #{tb.slug}."
            next
          else
            post.assign_attributes(post_data.compact)
            post.save!
            post_results[:updated] += 1
          end
        else
          post = tb.build_post(post_data.compact)
          post.save!
          post_results[:created] += 1
        end
      end
    end

    notice = "Import completato. Taxbranch creati: #{results[:created]}, aggiornati: #{results[:updated]}, saltati: #{results[:skipped]}. Post creati: #{post_results[:created]}, aggiornati: #{post_results[:updated]}, saltati: #{post_results[:skipped]}."
    if results[:errors].any?
      redirect_to export_import_superadmin_taxbranch_path(@taxbranch), alert: "#{notice} Errori: #{results[:errors].join(' | ')}"
    else
      redirect_to export_import_superadmin_taxbranch_path(@taxbranch), notice: notice
    end
  rescue CSV::MalformedCSVError => e
    redirect_to export_import_superadmin_taxbranch_path(@taxbranch), alert: "CSV non valido: #{e.message}"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_taxbranch
        @taxbranch =
          if Taxbranch.respond_to?(:friendly)
            Taxbranch.friendly.find(params[:id])
          else
            Taxbranch.find_by(id: params[:id]) || Taxbranch.find_by(slug: params[:id])
          end

        redirect_to superadmin_taxbranches_path, alert: "Taxbranch non trovato." if @taxbranch.nil?

  rescue ActiveRecord::RecordNotFound
    redirect_to superadmin_taxbranches_path, alert: "Taxbranch non trovato."
  end



   # Only allow a list of trusted parameters through.
   def taxbranch_params
    # Only allow a list of trusted parameters through.
    params.expect(taxbranch: [
      :lead_id, :notes, :slug, :slug_category, :slug_label,
      :ancestry, :position, :meta, :parent_id, :home_nav,
      :x_coordinated, :y_coordinated,
      :positioning_tag_public, :service_certificable,
      :status, :visibility, :phase, :published_at, :scheduled_at, :order_des,
      :permission_access_roles, :generaimpresa_md, { permission_access_roles: [] }
    ])
  end

  def load_domains
    @available_domains = Domain.order(:title)
  end

  def load_services_and_journeys
    @available_services = Service.order(:name)
    @available_journeys = Journey.order(:title)
  end

  def parse_bool(value)
    case value.to_s.strip.downcase
    when "1", "true", "yes", "y", "on"
      true
    when "0", "false", "no", "n", "off"
      false
    else
      nil
    end
  end
  end
end
  def load_rails4b_data
    @domain = @taxbranch.header_domain
    @direction = params[:direction].presence || "all"
    @type_filter = params[:type].presence || "all"
    @mode_filter = params[:mode].presence || params[:tab].presence || "all"
    @service = @taxbranch.service

    outgoing = Journey.where(taxbranch_id: @taxbranch.id)
    incoming = Journey.where(end_taxbranch_id: @taxbranch.id)
    base_scope =
      case @direction
      when "outgoing"
        outgoing
      when "incoming"
        incoming
      else
        Journey.where(id: outgoing.select(:id)).or(Journey.where(id: incoming.select(:id)))
      end

    @journeys = base_scope.includes(:taxbranch, :end_taxbranch, :service).order(updated_at: :desc)

    @journeys =
      case @mode_filter
      when "builders"
        @journeys.cycle_template
      when "drivers"
        @journeys.cycle_instance
      else
        @journeys
      end

    @journeys_by_type = {
      railservice: [],
      function: [],
      pure: []
    }

    @journeys.each do |journey|
      if journey.railservice?
        @journeys_by_type[:railservice] << journey
      elsif journey.journey_function?
        @journeys_by_type[:function] << journey
      else
        @journeys_by_type[:pure] << journey
      end
    end
  end
