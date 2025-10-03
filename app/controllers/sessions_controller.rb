# app/controllers/sessions_controller.rb

# class SessionsController < ApplicationController
#   allow_unauthenticated_access only: %i[new create]
#   rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

#   def new; end

#   def create
#     user = User.find_by(email: params[:email])
#     if user&.authenticate(params[:password])
#       start_new_session_for(user)
#       redirect_to after_authentication_url, notice: "Benvenuto!"
#     else
#       flash.now[:alert] = "Credenziali non valide"
#       render :new, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     terminate_session
#     redirect_to root_path, notice: "Logout effettuato."
#   end
# end


class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      reset_session
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Benvenuto!", status: :see_other # 303
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html         { redirect_to new_session_path, alert: "Try another email address or password." }
      end
    end
  end
  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
