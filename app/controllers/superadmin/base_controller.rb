# app/controllers/superadmin/base_controller.rb
class Superadmin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_superadmin!

  private

  def require_superadmin!
    unless current_user&.superadmin?
      redirect_to(root_path, alert: "Area riservata.")
    end
  end
end
