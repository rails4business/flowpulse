module Superadmin
  class TaxbranchesController < ApplicationController
    include RequireSuperadmin
 before_action :set_taxbranch, only: %i[
  show edit update destroy
  move_down move_up move_right move_left
  addparent
]

  # GET /taxbranches or /taxbranches.json
  def index
    if  params[:children_id]
      @taxbranches = Current.user.lead.taxbranches.where(ancestry: [ nil, "" ]).where.not(id: params[:children_id]).ordered
    else
      @taxbranches = Current.user.lead.taxbranches.where(ancestry: [ nil, "" ]).ordered
    end
  end

  # GET /taxbranches/1 or /taxbranches/1.json
  def show
     @children = @taxbranch.children.ordered
  end

  # GET /taxbranches/new
  def new
    @taxbranch = Current.user.lead.taxbranches.build

    @taxbranch.parent_id = params[:parent_id] if params[:parent_id].present?
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

    redirect_to(@taxbranch.parent || superadmin_taxbranches_path, notice: "Creato.", status: :see_other)
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end


def update
  if @taxbranch.update(taxbranch_params)
    redirect_to(@taxbranch.parent || superadmin_taxbranches_path, notice: "Taxbranch aggiornata.", status: :see_other) # 303
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_taxbranch
      @taxbranch = Taxbranch.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def taxbranch_params
      params.expect(taxbranch: [ :lead_id, :description, :slug, :slug_category, :slug_label, :ancestry, :position, :meta, :parent_id ])
    end
  end
end
