module MenuHelper
  # unica fonte di verità
  def main_menu_superadmin_items
    [
      { icon: "🏠", label: "Home", path: dashboard_home_path },
      { icon: "📆", label: "Evento", path: dashboard_evento_path },

      { icon: "🌳", label: "Taxbranch", path: superadmin_taxbranches_path },
      { icon: "🌐", label: "Domain", path: superadmin_domains_path },
      { icon: "📊", label: "Post", path: posts_path },

      { icon: "🖥️", label: "Services", path: superadmin_services_path },
      { icon: "📋", label: "Journeys", path: journeys_path },
      { icon: "📆", label: "EventDate", path: eventdates_path },
      { icon: "⚙️", label: "Commitments", path: commitments_path },

      { icon: "☎️", label: "Lead", path: superadmin_leads_path },
      { icon: "🧘", label: "Igiene Posturale", path: dashboard_igieneposturale_path },
      { icon: "📋", label: "Liste", path: dashboard_liste_path },

      {
        icon: "🧑‍💼",
        label: "Superadmin",
        path: dashboard_superadmin_path,
        if: -> { Current.user&.superadmin? }
      }
    ]
  end

  # controlla se il link è attivo
  def nav_active?(path)
    request.path == path
  end

  # classi base per link
  def nav_link_classes(active)
    base = "flex items-center p-2 rounded-lg text-sm transition whitespace-nowrap"
    active ?
      "#{base} bg-gray-100 text-gray-900 dark:bg-gray-700 dark:text-white font-semibold" :
      "#{base} text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700"
  end
end
