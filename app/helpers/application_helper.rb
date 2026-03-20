module ApplicationHelper
  def domain_role_label(role_name)
    role = role_name.to_s.strip
    return "Utente" if role.casecmp("member").zero?
    return "Superadmin" if role.casecmp("superadmin").zero?

    role.tr("_", " ").humanize
  end

  # Determines a sensible default taxbranch id for form usage.
  # Priority: explicit record value -> controller-provided @taxbranch ->
  # params hint -> domain default -> first taxbranch owned by the current lead.
  def default_taxbranch_id_for(record = nil)
    return record.taxbranch_id if record.respond_to?(:taxbranch_id) && record.taxbranch_id.present?

    if defined?(@taxbranch) && @taxbranch.present?
      return @taxbranch.id
    end

    return params[:taxbranch_id] if params[:taxbranch_id].present?

    domain_taxbranch_id =
      if Current.domain&.respond_to?(:taxbranch)
        Current.domain.taxbranch&.id
      end
    return domain_taxbranch_id if domain_taxbranch_id.present?

    Current.user&.lead&.taxbranches&.first&.id
  end

  def post_entry_link(post, taxbranch: nil)
    return nil unless post

    branch = taxbranch || post.try(:taxbranch)
    domain_host = branch&.header_domain&.host.presence
    request_host = try(:request)&.host

    if domain_host.present? && request_host.present? && domain_host.casecmp?(request_host)
      return main_app.post_path(post)
    end

    if domain_host.present?
      return main_app.post_url(post, host: domain_host)
    end

    main_app.post_path(post)
  rescue
    main_app.post_path(post)
  end

  def domain_language
    current_domain&.language.presence || "it"
  end

  def questionnaire_level_info(level_code:, score_total:, scoring:)
    levels = questionnaire_scoring_levels(scoring)
    return nil if levels.blank?

    total = score_total.to_f
    selected =
      if level_code.present?
        levels.find { |lvl| lvl["code"].to_s == level_code.to_s }
      end
    selected ||= levels.find do |lvl|
      min = lvl["min"].to_f
      max = lvl["max"].to_f
      total >= min && total <= max
    end
    return nil unless selected.is_a?(Hash)

    code = selected["code"].to_s
    palette = questionnaire_level_palette(code)

    {
      code: code,
      min: selected["min"],
      max: selected["max"],
      label: selected["label"].to_s.presence || code.humanize,
      interpretation: selected["interpretation"].to_s.presence,
      recommendation: selected["recommendation"].to_s.presence,
      emoji: palette[:emoji],
      badge_class: palette[:badge_class],
      chip_class: palette[:chip_class]
    }
  end

  def questionnaire_scoring_levels(scoring)
    hash = scoring.is_a?(Hash) ? scoring : {}
    raw_levels = hash["levels"] || hash[:levels]
    Array(raw_levels).select { |lvl| lvl.is_a?(Hash) }
  end

  def questionnaire_level_palette(level_code)
    code = level_code.to_s.downcase
    return {
      emoji: "🔴",
      badge_class: "border-red-200 bg-red-50 text-red-700",
      chip_class: "bg-red-100 text-red-700"
    } if code.include?("ross")

    return {
      emoji: "🟡",
      badge_class: "border-amber-200 bg-amber-50 text-amber-700",
      chip_class: "bg-amber-100 text-amber-700"
    } if code.include?("giall")

    return {
      emoji: "🟢",
      badge_class: "border-emerald-200 bg-emerald-50 text-emerald-700",
      chip_class: "bg-emerald-100 text-emerald-700"
    } if code.include?("verd")

    {
      emoji: "🔵",
      badge_class: "border-slate-200 bg-slate-50 text-slate-700",
      chip_class: "bg-slate-100 text-slate-700"
    }
  end
end
