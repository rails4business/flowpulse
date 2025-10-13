# app/constraints/authenticated_constraint.rb
class AuthenticatedConstraint
  def matches?(request)
    # Controlla se l'utente è autenticato
    user_id = request.session[:user_id]
    user_id.present? && User.exists?(id: user_id)
  end
end
