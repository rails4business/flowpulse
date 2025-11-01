module Superadmin
class LeadsController < ApplicationController
  allow_unauthenticated_access only: %i[ create ]
  before_action :set_lead, only: [ :show, :approve, :update, :edit ]
  before_action :require_referral_for_approval!, only: :approve



  # GET /leads or /leads.json
  def index
    # Mostra solo leads per cui l’utente ha visibilità, e solo quelli con user pending
    @leads = Lead.all
  end



  # GET /leads/1 or /leads/1.json
  def show
  end

  # GET /leads/new
  def new
    @lead = Lead.new(referral_lead_id: params[:ref])
  end

  # GET /leads/1/edit
  def edit
    @lead = Current.user.lead
  end





  def create
    @lead = Lead.new(lead_params)

    if @lead.save
      redirect_to @lead, notice: "Lead creato. Utente in stato pending."
    else
      respond_to do |format|
        format.html         { render "pages/signup", status: :unprocessable_entity }
        format.turbo_stream { render "pages/signup", status: :unprocessable_entity }
        format.json         { render json: { errors: @lead.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def approve
    @lead = Lead.find(params[:id])
    unless LeadApprovalRule.allowed?(Current.user, @lead)
      return redirect_to leads_path, alert: "Non autorizzato."
    end

    @lead.approve!(approver_lead: Current.user.lead)
    respond_to do |format|
      format.html { redirect_to leads_path, notice: "Utente approvato!" }
      format.json { render json: { id: @lead.id, approved: true } }
    end
  rescue => e
    respond_to do |format|
      format.html { redirect_to leads_path, alert: e.message }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end


  # PATCH/PUT /leads/1 or /leads/1.json
  def update
    respond_to do |format|
      if @lead.update(lead_params)
        format.html { redirect_to @lead, notice: "Lead was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @lead }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1 or /leads/1.json
  def destroy
    @lead.destroy!

    respond_to do |format|
      format.html { redirect_to leads_path, notice: "Lead was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_lead
    @lead = Lead.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def lead_params
    params.expect(lead: [ :name, :surname, :username_id, :email, :phone, :token, :user_id, :parent_id, :referral_lead_id, :meta ])
  end



  def require_referral_for_approval!
    # policy minimale: deve esistere un referral o l'approvatore avere permessi (es. superadmin)
    unless @lead.referral_lead_id.present? || current_user&.superadmin?
      redirect_to @lead, alert: "Manca il referral per approvare." and return
    end
  end
end
end
