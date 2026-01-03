module Superadmin
  class TaxbranchesController < ApplicationController
    include RequireSuperadmin

    before_action :set_taxbranch, only: %i[
      show edit update destroy journeys positioning set_link_child
      move_down move_up move_right move_left
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

    redirect_to(superadmin_taxbranch_path(@taxbranch.parent.id), notice: "Creato.", status: :see_other)
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end


def update
  if @taxbranch.update(taxbranch_params)
    redirect_to(superadmin_taxbranch_path(@taxbranch.parent.id), notice: "Taxbranch aggiornata.", status: :see_other) # 303
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
      :positioning_tag_public, :service_certificable,
      :status, :visibility, :phase, :published_at, :scheduled_at,
      :permission_access_roles, { permission_access_roles: [] }
    ])
  end

  def load_domains
    @available_domains = Domain.order(:title)
  end

  def load_services_and_journeys
    @available_services = Service.order(:name)
    @available_journeys = Journey.order(:title)
  end
  end
end
