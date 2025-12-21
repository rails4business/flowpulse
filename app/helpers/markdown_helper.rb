# app/helpers/markdown_helper.rb
require "redcarpet"

# Prova a caricare Rouge (per evidenziare il codice). Se manca, fai fallback.
begin
  require "rouge"
  require "rouge/plugins/redcarpet"
  MarkdownRenderer = Class.new(Redcarpet::Render::HTML) do
    include Rouge::Plugins::Redcarpet
  end
rescue LoadError
  MarkdownRenderer = Redcarpet::Render::HTML
end

module MarkdownHelper
  YOUTUBE_SHORTCODE_RE = /\[youtube\s+([^\]]+)\]/.freeze

  def markdown(text)
    return "".html_safe if text.blank?  # ← niente parentesi extra qui

    safe_text = text.to_s.gsub(YOUTUBE_SHORTCODE_RE) do
      attrs = Regexp.last_match(1)
      embed = build_youtube_embed(attrs)
      embed || ""
    end

    renderer = MarkdownRenderer.new(
      filter_html:   true,  # 🔒 blocca HTML crudo
      hard_wrap:     true,
      with_toc_data: true
    )

    md = Redcarpet::Markdown.new(
      renderer,
      fenced_code_blocks: true,
      autolink:           true,
      tables:             true,
      strikethrough:      true,
      underline:          true,
      highlight:          true,
      quote:              true,
      footnotes:          true
    )

    html = md.render(safe_text)
    sanitize(
      html,
      tags:        permitted_tags,
      attributes:  permitted_attributes,
      protocols:   %w[http https mailto]
    ).html_safe
  end

  private

  def permitted_tags
    %w[p br strong em a ul ol li pre code blockquote h1 h2 h3 h4 h5 h6
       table thead tbody tr th td hr img iframe]
  end

  def permitted_attributes
    %w[href title src alt width height allow allowfullscreen frameborder referrerpolicy]
  end

  def build_youtube_embed(attrs)
    id = extract_attr(attrs, "id")
    list = extract_attr(attrs, "list")

    return if id.blank? && list.blank?

    if id.present?
      video_id = sanitize_youtube_token(id)
      return unless video_id

      src = "https://www.youtube-nocookie.com/embed/#{video_id}"
    else
      list_id = sanitize_youtube_token(list)
      return unless list_id

      src = "https://www.youtube-nocookie.com/embed/videoseries?list=#{ERB::Util.url_encode(list_id)}"
    end

    %(<iframe width="560" height="315" src="#{src}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>)
  end

  def extract_attr(text, name)
    match = text.match(/#{Regexp.escape(name)}="([^"]+)"/)
    match && match[1]
  end

  def sanitize_youtube_token(token)
    return unless token.is_a?(String)

    token = token.strip
    return unless token.match?(/\A[A-Za-z0-9_-]{6,}\z/)

    token
  end
end
