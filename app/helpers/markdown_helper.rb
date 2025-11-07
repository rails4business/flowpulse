# app/helpers/markdown_helper.rb
require "redcarpet"

# Prova a caricare Rouge, ma non fallire se manca
begin
  require "rouge"
  require "rouge/plugins/redcarpet"
  MarkdownRenderer = Class.new(Redcarpet::Render::HTML) do
    include Rouge::Plugins::Redcarpet # evidenziazione se disponibile
  end
rescue LoadError
  MarkdownRenderer = Redcarpet::Render::HTML # fallback senza evidenziazione
end

module MarkdownHelper
  def markdown(text)
    return "".html_safe if text.blank?)

    renderer = MarkdownRenderer.new(
      filter_html:   true,   # 🔒 blocca HTML crudo
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

    html = md.render(text.to_s)
    sanitize(html, tags: permitted_tags, attributes: permitted_attributes).html_safe
  end

  private

  def permitted_tags
    %w[p br strong em a ul ol li pre code blockquote h1 h2 h3 h4 h5 h6 table thead tbody tr th td]
  end

  def permitted_attributes
    %w[href title]
  end
end
