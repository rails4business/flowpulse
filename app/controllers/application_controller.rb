class ApplicationController < ActionController::Base
  include CurrentDomainContext
  include Authentication
  include Pundit::Authorization

  # Rende policy()/policy_scope() disponibili anche nelle view
  helper_method :policy, :policy_scope

  # >>> Dillo a Pundit: l'utente corrente è Current.user (non current_user)
  def pundit_user
    Current.user
  end

  # (Consigliato) gestione elegante dei divieti
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized




  def pundit_user = Current.user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    redirect_to(request.referer || root_path, alert: "Non hai i permessi per questa azione.")
  end
end
