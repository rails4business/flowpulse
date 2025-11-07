# app/helpers/markdown_helper.rb
require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet" # evidenziazione codice opzionale

module MarkdownHelper
  class HTMLRenderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet  # abilita <pre><code> colorato
  end

  def markdown(text)
    return "".html_safe if text.blank?

    renderer = HTMLRenderer.new(
      filter_html: true,        # 🔒 blocca HTML diretto (sicurezza)
      hard_wrap: true,          # converte \n in <br>
      with_toc_data: true       # aggiunge id a <h1>, <h2>…
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      fenced_code_blocks: true,
      autolink: true,
      tables: true,
      strikethrough: true,
      underline: true,
      highlight: true,
      quote: true,
      footnotes: true
    )

    html = markdown.render(text.to_s)

    # ulteriore protezione contro XSS (ma lascia i tag utili)
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
