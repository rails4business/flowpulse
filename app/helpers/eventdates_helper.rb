module EventdatesHelper
  def eventdate_label(eventdate)
    eventdate.journey&.title.presence ||
      eventdate.description.presence ||
      eventdate.event_type.presence ||
      "Evento ##{eventdate.id}"
  end

  def eventdate_period(eventdate)
    if eventdate.date_start.present? && eventdate.date_end.present?
      "#{l(eventdate.date_start.to_date, format: :long)} · #{l(eventdate.date_start, format: :time)} – #{l(eventdate.date_end, format: :time)}"
    elsif eventdate.date_start.present?
      "#{l(eventdate.date_start.to_date, format: :long)} · #{l(eventdate.date_start, format: :time)}"
    elsif eventdate.date_end.present?
      "Fine: #{l(eventdate.date_end.to_date, format: :long)} · #{l(eventdate.date_end, format: :time)}"
    else
      "Nessuna data impostata"
    end
  end

  def eventdate_status_badge(eventdate)
    if eventdate.date_start.present? && eventdate.date_end.present?
      ["Date complete", "bg-emerald-50 text-emerald-700 border border-emerald-200"]
    elsif eventdate.date_start.present?
      ["Solo inizio", "bg-blue-50 text-blue-600 border border-blue-200"]
    else
      ["Da pianificare", "bg-amber-50 text-amber-700 border border-amber-200"]
    end
  end
end
