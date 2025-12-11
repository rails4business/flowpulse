module ApplicationHelper
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
end
