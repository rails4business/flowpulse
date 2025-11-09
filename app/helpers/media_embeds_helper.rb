module MediaEmbedsHelper
  # Entry point: prova prima l'iframe già incluso, poi YouTube URL
  def media_embed(raw_input)
    return if raw_input.blank?

    # 1) Se è già un iframe, lo sanitizzo e lo ritorno
    if raw_input.include?("<iframe")
      return sanitize(raw_input,
        tags: %w[iframe],
        attributes: %w[src width height title frameborder allow allowfullscreen referrerpolicy loading])
    end

    # 2) Se è un URL YouTube/Youtu.be, creo l'embed
    if (info = extract_youtube_info(raw_input))
      return youtube_iframe(info[:id], start: info[:start])
    end

    nil
  end

  # Parsiamo vari formati YouTube (youtu.be, watch?v=, shorts, m.youtube)
  def extract_youtube_info(url_str)
    uri = URI.parse(url_str) rescue nil
    return nil unless uri&.host

    host = uri.host.downcase
    return nil unless host.include?("youtube.com") || host.include?("youtu.be")

    id = nil
    start_seconds = nil

    # Path/params
    if host.include?("youtu.be")
      # https://youtu.be/VIDEO_ID?t=90
      id = uri.path.split("/").last
      start_seconds = parse_start_param(CGI.parse(uri.query.to_s))
    else
      # youtube.com
      if uri.path.start_with?("/shorts/")
        # https://www.youtube.com/shorts/VIDEO_ID?...
        id = uri.path.split("/")[2]
      else
        # https://www.youtube.com/watch?v=VIDEO_ID&...
        params = CGI.parse(uri.query.to_s)
        id = params["v"]&.first
        start_seconds = parse_start_param(params)
      end
    end

    return nil if id.blank?
    { id: id, start: start_seconds }
  end

  # Supporta t=90, t=1m30s, start=90
  def parse_start_param(params)
    t = params["t"]&.first || params["start"]&.first
    return nil if t.blank?

    if t =~ /\A\d+\z/
      t.to_i
    else
      # formato tipo 1h2m3s / 2m30s / 45s
      hours   = t[/(\d+)h/, 1].to_i
      minutes = t[/(\d+)m/, 1].to_i
      seconds = t[/(\d+)s/, 1].to_i
      total = hours * 3600 + minutes * 60 + seconds
      total.positive? ? total : nil
    end
  end

  # Wrapper responsive + iframe sicuro
  def youtube_iframe(video_id, start: nil)
    src = "https://www.youtube.com/embed/#{ERB::Util.url_encode(video_id)}"
    src += "?start=#{start.to_i}" if start

    content_tag(:div, class: "relative w-full overflow-hidden rounded-xl shadow-sm",
                      style: "aspect-ratio: 16 / 9;") do
      content_tag(:iframe, "",
        src: src,
        title: "YouTube video player",
        loading: "lazy",
        allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share",
        allowfullscreen: true,
        referrerpolicy: "strict-origin-when-cross-origin",
        frameborder: "0",
        class: "absolute inset-0 h-full w-full")
    end
  end
end
