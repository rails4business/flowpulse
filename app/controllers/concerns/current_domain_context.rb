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

    # 1️⃣ prova a risolvere dal cache o dal resolver
    Current.domain = Rails.cache.fetch("domain:#{host}", expires_in: 10.minutes) do
      DomainResolver.resolve(host)
    end

    # 2️⃣ se non trovato, fallback
    if Current.domain.nil?
      Rails.logger.warn "⚠️ Nessun dominio trovato per #{host}"

      # Prova a usare il primo dominio esistente
      Current.domain = Domain.first

      # 3️⃣ Se non esiste alcun dominio, crea tutto da zero
      if Current.domain.nil?
        Rails.logger.warn "⚙️ Creo dominio di default per #{host}"

        # assicurati di avere almeno un taxbranch root
        taxbranch = Taxbranch.first || Taxbranch.create!(
          slug: "root",
          slug_label: "Root",
          slug_category: "system",
          description: "Nodo principale del sistema"
        )

        Current.domain = Domain.create!(
          host: host,
          language: I18n.default_locale.to_s,
          title: "Default Domain",
          description: "Dominio generato automaticamente per #{host}",
          taxbranch: taxbranch
        )

        # aggiorna la cache per non ripetere ogni volta
        Rails.cache.write("domain:#{host}", Current.domain, expires_in: 10.minutes)
      end
    end

    # 4️⃣ sincronizza il taxbranch
    Current.taxbranch = Current.domain&.taxbranch
  end

  def set_locale_from_domain
    I18n.locale = Current.domain&.language.presence || I18n.default_locale
  end
end
