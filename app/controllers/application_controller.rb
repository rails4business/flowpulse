class ApplicationController < ActionController::Base
  include Authentication
  before_action :set_current_domain
  before_action :set_locale_from_domain
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern




  private

  def set_current_domain
    dom = DomainResolver.resolve(request.host)
    if dom
      Current.domain    = dom
      Current.taxbranch = dom.taxbranch
    end
  end

  def set_locale_from_domain
    I18n.locale = Current.domain&.language.presence || I18n.default_locale
  end
end
