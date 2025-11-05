# app/controllers/superadmin/leads_controller.rb
module Superadmin
  class LeadsController < ApplicationController
    include RequireSuperadmin

    before_action :set_lead, only: %i[show edit update destroy approve]
    before_action :require_referral_for_approval!, only: :approve

    # GET /superadmin/leads
    def index
      # mostra tutti i lead (filtra qui se vuoi solo pending ecc.)
      @leads = Lead.order(created_at: :desc).page(params[:page])
    end

    # GET /superadmin/leads/:id
    def show; end

    # GET /superadmin/leads/new
    def new
      @lead = Lead.new(referral_lead_id: params[:ref])
    end

    # GET /superadmin/leads/:id/edit
    def edit; end

    # POST /superadmin/leads
    def create
      @lead = Lead.new(lead_params_sanitized)

      if @lead.save
        redirect_to [ :superadmin, @lead ],
                    notice: "Lead creato. Utente in stato pending."
      else
        respond_to do |format|
          format.html         { render "pages/signup", status: :unprocessable_entity }
          format.turbo_stream { render "pages/signup", status: :unprocessable_entity }
          format.json         { render json: { errors: @lead.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /superadmin/leads/:id
    def update
      if @lead.update(lead_params_sanitized)
        redirect_to [ :superadmin, @lead ],
                    notice: "Lead aggiornato.",
                    status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /superadmin/leads/:id
    def destroy
      @lead.destroy!
      redirect_to superadmin_leads_path,
                  notice: "Lead eliminato.",
                  status: :see_other
    end

    # PATCH /superadmin/leads/:id/approve
    def approve
      unless LeadApprovalRule.allowed?(Current.user, @lead)
        return redirect_to superadmin_leads_path, alert: "Non autorizzato."
      end

      @lead.approve!(approver_lead: Current.user.lead)

      respond_to do |format|
        format.html { redirect_to superadmin_leads_path, notice: "Utente approvato!" }
        format.json { render json: { id: @lead.id, approved: true } }
      end
    rescue => e
      respond_to do |format|
        format.html { redirect_to [ :superadmin, @lead ], alert: e.message }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end

    private

    def set_lead
      @lead = Lead.find(params.expect(:id))
    rescue ActiveRecord::RecordNotFound
      redirect_to superadmin_leads_path, alert: "Lead non trovato."
    end

    # Non permettere :user_id dal form; lo gestisci tu lato server quando serve.
    # Correggi :username_id -> :username
    def lead_params_sanitized
      params.expect(lead: %i[name surname username email phone token parent_id referral_lead_id meta])
    end

    def require_referral_for_approval!
      # policy minima: serve referral o superadmin
      unless @lead.referral_lead_id.present? || Current.user&.superadmin?
        redirect_to [ :superadmin, @lead ], alert: "Manca il referral per approvare."
      end
    end
  end
end
