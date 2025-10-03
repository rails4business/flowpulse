class ApplicationController < ActionController::Base
  include Authentication

  before_action :set_current_brand_and_host
  before_action :set_current_user

  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    Current.user
  end

  def set_current_brand_and_host
    host = request.host.to_s.downcase.sub(/\Awww\./, "")

    base = request.domain.presence || host.split(".", 2).last
    sub  = host.delete_suffix(".#{base}")

    Current.subdomain = (sub == base ? nil : sub)
    Current.base_host = base
    Current.brand     = Brand.for_host(base)
  rescue ActiveRecord::RecordNotFound
    Current.brand = nil
  end

  def set_current_user
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  def current_user
    Current.user
  end
end
