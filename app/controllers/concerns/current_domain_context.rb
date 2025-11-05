# app/controllers/concerns/current_domain_context.rb
module CurrentDomainContext
  extend ActiveSupport::Concern

  included do
    before_action :set_current_domain
    before_action :set_locale_from_domain
  end

  private

  def set_current_domain
    host = request.host

    Current.domain = Rails.cache.fetch("domain:#{host}", expires_in: 10.minutes) do
      DomainResolver.resolve(host)
    end

    if Current.domain.nil?
      Rails.logger.warn "⚠️ Nessun dominio configurato per #{host}"
      # Fallback “soft”: usa il primo se esiste
      Current.domain = Domain.first
      if Current.domain.nil?
        # In produzione alza errore chiaro; in dev guida al bootstrap
        if Rails.env.production?
          raise ActiveRecord::RecordNotFound, "Dominio non configurato per #{host}. Esegui il bootstrap (seeds)."
        else
          redirect_to unauthenticated_root_path, alert: "Devi eseguire `rails db:seed` per creare dominio e radice." and return
        end
      end
    end

    Current.taxbranch = Current.domain.taxbranch
  end

  def set_locale_from_domain
    I18n.locale = Current.domain&.language.presence || I18n.default_locale
  end
end
