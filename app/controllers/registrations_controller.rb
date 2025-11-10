# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: [ :create ]
  layout "posts", only: [ :new, :create ]
  def create
    referral_username = signup_params[:referral_code].presence
    referral_lead_id  = Lead.find_by(username: referral_username)&.id if referral_username

    email    = signup_params[:email].to_s.strip
    password = signup_params[:password]

    # Se serve username per il flow
    provisional_username = generate_username_from(email)

    flow = LeadSignupFlow.new.call!(
        lead_params: { email: email, username: provisional_username },
        password: password,
        referral_lead_id: referral_lead_id,
        auto_approve: true
      )

    start_new_session_for(flow.user)
    redirect_to after_authentication_url, notice: "Benvenuto! Account creato."
  rescue ActiveRecord::RecordInvalid => e
    @lead = Lead.new(signup_params)
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render "sessions/new", status: :unprocessable_entity
  end

  def edit
    @user = Current.user
    @lead = @user.lead || Lead.find_by(email: @user.email_address) || Lead.new(email: @user.email_address, username: default_username(@user))
  end

  def update
    @user = Current.user
    @lead = @user.lead || Lead.find_by(email: @user.email_address) || Lead.new(email: @user.email_address, username: default_username(@user))

    ActiveRecord::Base.transaction do
      @user.update!(user_params)
      if @lead.new_record?
        @lead.assign_attributes(lead_params)
        @lead.user_id ||= @user.id if @lead.respond_to?(:user_id)
        @lead.save!
      else
        @lead.update!(lead_params)
      end
    end

    redirect_to after_authentication_url, notice: "Profilo aggiornato!"
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :edit, status: :unprocessable_entity
  end

  private

  def user_params
    # aggiungi/limita i campi che vuoi rendere modificabili
    params.require(:user).permit(:name, :surname, :phone, :email_address, :password, :password_confirmation)
  end

  def lead_params
    # username e altri campi lato lead
    params.fetch(:lead, {}).permit(:username, :phone, :notes)
  end

  def default_username(user)
    user.email_address.to_s.split("@").first.to_s.parameterize.presence || "utente"
  end



  def signup_params
    params.require(:lead).permit(:email, :password, :referral_code)
  end

  def generate_username_from(email)
    base = email.to_s.split("@").first.to_s.parameterize.presence || "user"
    uname = base
    i = 1
    while Lead.exists?(username: uname)
      i += 1
      uname = "#{base}-#{i}"
      break if i > 1000
    end
    uname
  end
end
