# app/helpers/posts_helper.rb
module PostsHelper
  def sortable(column, title = nil)
    title ||= column.titleize

    current = (column == sort_column)
    direction = (current && sort_direction == "asc") ? "desc" : "asc"

    link = link_to(
      safe_join([ title, sort_icon(column) ]),
      params.permit(:taxbranch_id, :status, :after, :before).merge(sort: column, direction: direction, page: nil),
      class: "inline-flex items-center gap-1 hover:underline"
    )

    link
  end

  def sort_icon(column)
    return "" unless column == sort_column

    # frecce con aria-label accessibile
    arrow = sort_direction == "asc" ? "↑" : "↓"
    content_tag(:span, arrow, class: "text-xs align-middle", aria: { label: sort_direction })
  end

  def status_badge(post)
    case post.status.to_s
    when "published"
      klass = "bg-emerald-100 text-emerald-800"
      label = "Pubblicato"
    when "draft"
      klass = "bg-amber-100 text-amber-800"
      label = "Bozza"
    when "archived"
      klass = "bg-slate-200 text-slate-700"
      label = "Archiviato"
    else
      klass = "bg-slate-200 text-slate-700"
      label = post.status.to_s.titleize
    end
    content_tag(:span, label, class: "px-2 py-0.5 rounded text-xs font-medium #{klass}")
  end

  def fmt_datetime(dt)
    dt.present? ? l(dt, format: :short) : "—"
  end
end
