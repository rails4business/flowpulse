module PostsHelper
  def post_media_url(post)
    return nil unless post

    direct_media =
      if post.respond_to?(:url_media_content)
        post.url_media_content.presence
      end
    fallback_media =
      if post.respond_to?(:media_url)
        post.media_url.presence
      end

    direct_media || fallback_media
  end

  def post_image_url(post)
    return nil unless post

    post.horizontal_cover_url.presence ||
      post.thumb_url.presence ||
      post.banner_url.presence ||
      post.vertical_cover_url.presence
  end

  def post_taxbranch_post_category?(post)
    post&.taxbranch&.slug_category.to_s == "post"
  end

  # ---------------------------------------------------------
  # LINK ORDINABILE (colonne)
  # ---------------------------------------------------------
  def sortable(column, title = nil)
    title ||= column.titleize

    current = (column == sort_column)
    direction = (current && sort_direction == "asc") ? "desc" : "asc"

    link_to(
      safe_join([ title, sort_icon(column) ]),
      params.permit(:taxbranch_id, :status, :after, :before)
            .merge(sort: column, direction: direction, page: nil),
      class: "inline-flex items-center gap-1 hover:underline"
    )
  end

  # ---------------------------------------------------------
  # ICONA ORDINAMENTO
  # ---------------------------------------------------------
  def sort_icon(column)
    return "" unless column == sort_column

    arrow = sort_direction == "asc" ? "↑" : "↓"
    content_tag(:span, arrow, class: "text-xs align-middle", aria: { label: sort_direction })
  end

  # ---------------------------------------------------------
  # STATUS BADGE (adesso su TAXBRANCH)
  # ---------------------------------------------------------
  def status_badge(post)
    tb = post.taxbranch

    return content_tag(:span, "—", class: badge_klass("default")) unless tb

    case tb.status
    when "published"
      content_tag(:span, "Pubblicato", class: badge_klass("published"))
    when "draft"
      content_tag(:span, "Bozza", class: badge_klass("draft"))
    when "in_review"
      content_tag(:span, "In revisione", class: badge_klass("review"))
    when "archived"
      content_tag(:span, "Archivio", class: badge_klass("archived"))
    else
      content_tag(:span, tb.status.to_s.titleize, class: badge_klass("default"))
    end
  end

  # classi Tailwind per badge
  def badge_klass(type)
    case type
    when "published" then "px-2 py-0.5 rounded text-xs font-medium bg-emerald-100 text-emerald-800"
    when "draft"     then "px-2 py-0.5 rounded text-xs font-medium bg-amber-100 text-amber-800"
    when "review"    then "px-2 py-0.5 rounded text-xs font-medium bg-sky-100 text-sky-700"
    when "archived"  then "px-2 py-0.5 rounded text-xs font-medium bg-slate-200 text-slate-700"
    else                  "px-2 py-0.5 rounded text-xs font-medium bg-slate-100 text-slate-600"
    end
  end

  # ---------------------------------------------------------
  # FORMATO DATA (per published_at → taxbranch)
  # ---------------------------------------------------------
  def fmt_datetime(dt)
    dt.present? ? l(dt, format: :short) : "—"
  end
end
