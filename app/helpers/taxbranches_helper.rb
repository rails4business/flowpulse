module TaxbranchesHelper
  # node:         il taxbranch corrente (es. @post.taxbranch o @taxbranch)
  # starting_node: taxbranch da cui far partire il breadcrumb (es. Current.domain.taxbranch)
  def taxbranch_breadcrumb(node, starting_node: nil)
    return "" unless node

    # Con Ancestry: path = [root, ..., parent, self]
    path =
      if node.respond_to?(:path)
        node.path.to_a
      else
        # fallback robusto: ancestors (root → parent) + self
        node.ancestors.to_a + [ node ]
      end

    if starting_node
      idx = path.index(starting_node)
      path = idx ? path[idx..] : path
    end

    content_tag :nav, aria: { label: "breadcrumb" }, class: "mb-2 text-sm text-slate-500 dark:text-slate-400" do
      safe_join(
        path.map.with_index do |branch, i|
          last = (i == path.size - 1)

          if last
            content_tag(:span, branch.display_label, class: "font-semibold text-slate-900 dark:text-white")
          else
            link_to(branch.display_label, superadmin_taxbranch_path(branch), class: "hover:underline") +
              content_tag(:span, " / ", class: "mx-1 text-gray-400")
          end
        end
      )
    end
  end
  # app/helpers/taxbranch_helper.rb

  # 16 colori pastello "fissi"
  PASTEL_COLORS = %w[
      #FAFAFA
      #F2F4F7
      #FCE7EB
      #F7DDF5
      #E7E0FB
      #DDE9FC
      #D5F0FB
      #D6F6F0
      #DDF8E4
      #F0F9D9
      #FFF8D1
      #FFE9D2
      #FFDCD5
      #F8DCE3
      #EFDDF5
      #E0E4FF
  ].freeze

  # Solo background
  def pastel_bg_for_category(category)
    slug = category.to_s
    return "" if slug.blank?

    bg_color = pastel_color_for_slug(slug)
    "background-color: #{bg_color};"
  end

  # Badge: bg pastello + testo scuro leggibile
  def pastel_style_for_category(category)
    slug = category.to_s
    return "background-color: #e5e7eb; color: #111827;" if slug.blank?
    # fallback: slate-200 / gray-900

    bg_color = pastel_color_for_slug(slug)
    "background-color: #{bg_color}; color: #111827;"
  end

  private

  # Trasforma la stringa in un indice stabile per i 16 colori
  # Usa tutte le lettere (somma dei byte) → modulo lunghezza palette
  def pastel_color_for_slug(slug)
    sum = slug.each_byte.sum
    index = sum % PASTEL_COLORS.size
    PASTEL_COLORS[index]
  end
end
