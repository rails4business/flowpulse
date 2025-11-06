module Superadmin
  class TaxbranchesController < ApplicationController
    include RequireSuperadmin
    before_action :set_taxbranch, only: %i[
      show edit update destroy
      move_down move_up move_right move_left
      addparent positioning
    ]

  # GET /taxbranches or /taxbranches.json
  def index
      scope =
      if Current.user&.superadmin?
        Taxbranch.all
      else
        # se per qualche motivo arrivi qui senza lead → nessun record
        Current.user&.lead&.taxbranches || Taxbranch.none
      end

    @taxbranches = scope.where(ancestry: [ nil, "" ]).ordered
  end

  # GET /taxbranches/1 or /taxbranches/1.json
  def show
     @children = @taxbranch.children.ordered


     @post = @taxbranch.post || @taxbranch.build_post(lead: Current.user&.lead)

    # mode: "show" | "edit" | "new"
    @mode =
      if params[:mode].in?(%w[show edit new])
        params[:mode]
      else
        @post.persisted? ? "show" : "new"
      end
  end

  # GET /taxbranches/new
  def new
    @taxbranch = Current.user.lead.taxbranches.build
    if params[:parent_id]
      @taxbranch.parent_id = params[:parent_id] if params[:parent_id].present?
    end
  end

  # GET /taxbranches/1/edit
  def edit
  end

  def addparent
    Taxbranch.find(params[:children_id]).update(parent_id: @taxbranch.id)
    redirect_to @taxbranch
  end

  # POST /taxbranches or /taxbranches.json
  def create
    scope = Current.user.lead.taxbranches
    @taxbranch = scope.build(taxbranch_params)

    # fallback dal query string se non inviato nel form
    @taxbranch.parent_id ||= params[:parent_id].presence

    children_id = params[:children_id].presence

    Taxbranch.transaction do
      @taxbranch.save!

      if children_id
        child = scope.find(children_id)
        # opzionale: evita edge cases
        raise ActiveRecord::RecordInvalid, @taxbranch if child.id == @taxbranch.id

        child.update!(parent_id: @taxbranch.id)
      end
    end

    redirect_to(superadmin_taxbranches_path(@taxbranch.parent)  || superadmin_taxbranches_path, notice: "Creato.", status: :see_other)
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end


def update
  if @taxbranch.update(taxbranch_params)
    redirect_to(superadmin_taxbranches_path(@taxbranch.parent)   || superadmin_taxbranches_path, notice: "Taxbranch aggiornata.", status: :see_other) # 303
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
    rows = @taxbranch.tag_positionings
    counts = rows.group(:name, :category).count
    @items = counts.map { |(name, cat), n| { text: name, count: n, cat: cat } }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_taxbranch
    @taxbranch =
      if defined?(Taxbranch.friendly)
        Taxbranch.friendly.find(params[:id])
      else
        Taxbranch.find_by(id: params[:id]) || Taxbranch.find_by(slug: params[:id])
      end
  rescue ActiveRecord::RecordNotFound
    redirect_to superadmin_taxbranches_path, alert: "Taxbranch non trovato."
  end



    # Only allow a list of trusted parameters through.
    def taxbranch_params
      params.expect(taxbranch: [ :lead_id, :description, :slug, :slug_category, :slug_label, :ancestry, :position, :meta, :parent_id, :home_nav, :positioning_tag_public ])
    end
  end
end
