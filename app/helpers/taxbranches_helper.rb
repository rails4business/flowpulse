# app/helpers/taxbranches_helper.rb
module TaxbranchesHelper
  # Titolo o etichetta leggibile di un ramo
  def taxbranch_label(node)
    node.slug_label.presence || node.description.presence || node.slug.titleize
  end

  # Breadcrumb universale:
  #   - per l’admin: "Tutte le tassonomie › ... › Nodo"
  #   - per il pubblico: "🏠 Home › ... › Nodo"
  #
  # Opzioni:
  #   - admin: true → usa percorsi superadmin
  #   - root_label: personalizza la label iniziale
  #   - home_icon: true/false per mostrare l’emoji in pubblico
  #
  def taxbranch_breadcrumb(node, admin: false, root_label: nil, home_icon: true)
    return "" unless node.present?

    trail = node.ancestors + [ node ]
    parts = []

    # === Link iniziale ===
    if admin
      parts << link_to(root_label || "Tutte le tassonomie",
                       superadmin_taxbranches_path,
                       class: "hover:underline text-slate-600")
    else
      label = [ ("🏠" if home_icon), (root_label || "Home") ].compact.join(" ")
      parts << link_to(label,
                       unauthenticated_root_path,
                       class: "hover:underline text-slate-600")
    end

    # === Antenati come link ===
    trail[0..-2].each do |ancestor|
      path =
        if admin
          superadmin_taxbranch_path(ancestor)
        elsif defined?(treepage_path)
          treepage_path(ancestor.slug)
        elsif defined?(gate_path)
          gate_path(ancestor.slug)
        else
          unauthenticated_root_path
        end

      parts << link_to(taxbranch_label(ancestor),
                       path,
                       class: "hover:underline text-slate-600")
    end

    # === Nodo corrente (non link) ===
    parts << content_tag(:span,
                         taxbranch_label(node),
                         class: "text-slate-800 font-semibold")

    # === Join con separatore › ===
    safe_join(parts, content_tag(:span, " › ", class: "text-slate-400"))
  end
end
