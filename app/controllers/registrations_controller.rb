# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: [ :create ]

  def create
    referral_username = signup_params[:referral_code]
    referral_lead_id  = Lead.find_by(username: referral_username)&.id if referral_username.present?

    flow = LeadSignupFlow.new.call!(
      lead_params: signup_params.slice(:name, :surname, :username, :email, :phone),
      password: signup_params[:password],
      referral_lead_id: referral_lead_id,
      auto_approve: true
    )

    start_new_session_for(flow.user)   # 👈 questo è il login
    redirect_to after_authentication_url, notice: "Benvenuto! Account creato."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render "sessions/new", status: :unprocessable_entity
  end

  private

  def signup_params
    params.require(:lead).permit(:name, :surname, :username, :email, :phone, :password, :referral_code)
  end
end
