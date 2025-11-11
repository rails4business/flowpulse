# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  layout "posts", only: %i[new create]

  def new
  @lead ||= Lead.new
  @referrer = locate_referrer(params[:ref], params.dig(:lead, :referral_code))
  @user = User.new
  if params[:ref].present? && @referrer.nil?
    flash.now[:alert] = "Link invito non valido, scaduto o referrer non abilitato."
  elsif @referrer && !@referrer.can_invite?
    flash.now[:alert] = "Questo invito non è più disponibile."
    @referrer = nil
  end
end

  def create
    # preferisci token firmato se presente
    referrer = locate_referrer(params[:ref], signup_params[:referral_code])

    email    = signup_params[:email].to_s.strip
    password = signup_params[:password]

    provisional_username = generate_username_from(email)

    # Se il referrer non è valido/abilitato, ignoralo
    referrer = nil unless referrer&.can_invite?

    flow = LeadSignupFlow.new.call!(
      lead_params: { email: email, username: provisional_username },
      password: password,
      referral_lead_id: nil,      # non più da username, usiamo referrer se c'è
      auto_approve: false         # il Tutor approva
    )

    # collega il referrer (se valido)
    if referrer
      flow.user.update!(referrer_id: referrer.id)
    end

    start_new_session_for(flow.user)

    # conteggia solo se c'è referrer valido
    referrer&.count_successful_invite!

    redirect_to after_authentication_url, notice: "Benvenuto! Account creato."
  rescue ActiveRecord::RecordInvalid => e
    @lead = Lead.new(signup_params)
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity   # <- invece di "sessions/new"
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
      @lead = Lead.new(signup_params)
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
  end

  private

  def locate_referrer(signed_ref, legacy_ref_code)
    # 1) token firmato
    if signed_ref.present?
      user = User.find_signed(signed_ref, purpose: :referral) rescue nil
      return (user if user&.approved_referrer?)
    end

    # 2) fallback legacy: username nel Lead (come prima)
    if legacy_ref_code.present?
      lead = Lead.find_by(username: legacy_ref_code)
      user = lead&.user
      return (user if user&.approved_referrer?)
    end

    nil
  end

  def user_params
    params.require(:user).permit(:name, :surname, :phone, :email_address, :password, :password_confirmation)
  end

  def lead_params
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
