# app/controllers/superadmin/leads_controller.rb
class Superadmin::LeadsController < ApplicationController
  include Pundit::Authorization

  before_action :set_lead, only: %i[show edit update destroy approve]

  # Pundit user (se usi Current.user)
  def pundit_user
    Current.user
  end

  def index
    @leads = Lead.includes(:user).order(created_at: :desc).page(params[:page])
    authorize Lead
  end

  def show
    authorize @lead
  end

  def new
    @lead = Lead.new
    authorize @lead
  end

  def create
    @lead = Lead.new(lead_params)
    authorize @lead
    if @lead.save
      redirect_to [ :superadmin, @lead ], notice: "Lead creato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @lead
  end

  def update
    authorize @lead
    if @lead.update(lead_params)
      redirect_to [ :superadmin, @lead ], notice: "Lead aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @lead
    @lead.destroy
    redirect_to superadmin_leads_path, notice: "Lead eliminato."
  end

  def approve
    authorize @lead, :approve?

    user = @lead.user || User.new(lead: @lead, email: @lead.email)
    user.state_registration = :approved
    user.approved_by_lead_id = Current.user&.lead_id if user.respond_to?(:approved_by_lead_id)

    if user.save
      redirect_to [ :superadmin, @lead ], notice: "Lead approvato."
    else
      redirect_to [ :superadmin, @lead ], alert: "Errore: #{user.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:email, :name, :referral_lead_id) # adatta ai tuoi campi
  end
end
