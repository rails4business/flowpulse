module TaxbranchesHelper
  def taxbranch_label(node)
    node.description.presence || node.slug_label.presence || node.slug
  end

  # Breadcrumb: "Tutte le tassonomie › … › Nodo corrente"
  # L'ultimo elemento è testo (non link) per evitare la ripetizione.
  def taxbranch_breadcrumb(node)
    trail = node.ancestors + [ node ]

    parts = []
    parts << link_to("Tutte le tassonomie", superadmin_taxbranches_path)

    # Tutti gli antenati come link
    trail[0..-2].each do |n|
      parts << link_to(taxbranch_label(n), superadmin_taxbranch_path(n))
    end

    # Nodo corrente come testo (non link)
    parts << content_tag(:span, taxbranch_label(node), class: "text-slate-700")

    safe_join(parts, content_tag(:span, " › ", class: "text-slate-400"))
  end
end
