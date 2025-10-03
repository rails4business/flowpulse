# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
    helper_method :current_user, :user_signed_in?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :authenticate_user, **options, raise: false
    end
  end

  private

  # ===== Pubbliche (helper) =====
  def current_user    = Current.user
  def user_signed_in? = Current.user.present?

  # ===== Auth gate =====
  def authenticate_user
    resume_session_and_user || request_authentication
  end
  alias_method :require_authentication, :authenticate_user

  # ===== Session handling =====
  def resume_session_and_user
    # 1) Preferisci la sessione Rails (classica)
    if session[:user_id].present?
      Current.user    ||= User.find_by(id: session[:user_id])
      Current.session ||= Session.find_by(user_id: session[:user_id]) # opzionale
    end

    # 2) Fallback: cookie app-specific (sessione a DB)
    if Current.user.blank?
      Current.session ||= find_session_by_cookie
      Current.user    ||= Current.session&.user
    end

    Current.user.present?
  end

  def find_session_by_cookie
    sid = cookies.signed[:session_id]
    return unless sid
    Session.includes(:user).find_by(id: sid)
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path, status: :see_other
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    # Evita fixation e azzera sessione Rails
    reset_session

    # ✨ Imposta SEMPRE anche la sessione Rails classica
    session[:user_id] = user.id

    # ✨ Imposta Current per la response corrente
    Current.user = user

    # ✨ (Opzionale ma utile) persisti una "Session" a DB e scrivi il cookie custom
    new_sess = user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
    Current.session = new_sess

    # Cookie firmato per la sessione applicativa (scegli durata/domains a piacere)
    cookies.signed[:session_id] = {
      value: new_sess.id,
      httponly: true,
      same_site: :lax,
      expires: 30.days.from_now
      # domain: (Rails.env.production? ? :all : nil), # se vuoi condividere tra subdomini in prod
    }

    new_sess
  end

  def terminate_session
    # Cancella record DB (se vuoi invalidare anche lato server)
    Current.session&.destroy

    # Pulisci cookie custom e Rails session
    cookies.delete(:session_id)
    reset_session

    Current.session = nil
    Current.user    = nil
  end
end
