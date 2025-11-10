class SessionsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  layout "posts"

  def new
    redirect_to after_authentication_url if Current.user
  end

  def create
    identifier = params[:email_address].to_s.strip.downcase
    password   = params[:password]

    # Trova l’utente per email o username (case-insensitive)
    user = User.where("LOWER(email_address) = :id OR LOWER(username) = :id", id: identifier).first

    if user&.authenticate(password)
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: "Bentornato!"
    else
      flash.now[:alert] = "Credenziali non valide."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to unauthenticated_root_path, notice: "Disconnesso."
  end
end
