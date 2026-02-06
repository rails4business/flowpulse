class BooksController < ApplicationController
  layout false

  allow_unauthenticated_access only: %i[index show presale]

  BOOK_ONLINE_SERVICE_SLUG = "libro-online-il-corpo-un-mondo-da-scoprire"
  # Access options:
  # - hidden: sempre nascosto e bloccato
  # - draft: non pubblicato (bloccato)
  # - free: pubblico
  # - registered: visibile/leggibile solo con login
  # - reg_hide: come registered, ma nascosto dall'indice se non loggato
  # - payment: visibile/leggibile solo se pagato
  # - pay_hide: come payment, ma nascosto dall'indice se non pagato

  def index
    @toc = Books::TocService.new.call.select { |item| access_visible_in_index?(item[:access]) }
  end

  def presale
    # Renders app/views/books/presale.html.erb
  end

  def show
    slug = params[:id].to_s
    
    # Try multiple file naming conventions to find the markdown file
    # The slug in YAML might match the filename directly or contain hints.
    # The files in book_official are named like "047-eventi-seminari-a-tema.md"
    # The slugs in YAML are like "eventi-seminari-a-tema" or "047-..."
    
    # We perform a glob search to find the file that *contains* the slug if exact match fails
    # Security: Ensure slug is safe (alphanumeric+dashes)
    safe_slug = slug.gsub(/[^a-zA-Z0-9\-_\.]/, '')
    safe_slug_base = safe_slug.sub(/\.md\z/, '')
    
    dir = Rails.root.join("config", "data", "book_official")
    
    file_path = find_book_file(dir, safe_slug_base)

    if file_path && File.exist?(file_path)
      raw = File.read(file_path)
      frontmatter, body = extract_frontmatter(raw)
      access = normalize_access(frontmatter["access"])

      if access_blocked?(access)
        return redirect_to(book_presale_path, alert: "Il libro è in prevendita: puoi acquistarlo per sostenere il progetto o seguire l'avanzamento.")
      end

      toc = Books::TocService.new.call
      chapters = toc.reject { |item| item[:header] }

      normalize = ->(s) { s.to_s.sub(/\.md\z/, '') }
      current_index = chapters.index { |c| normalize.call(c[:slug]) == normalize.call(slug) }

      @chapter_markdown = body
      @chapter_meta = frontmatter
      @chapter_title = frontmatter["title"] || chapters[current_index]&.dig(:title) || slug
      @chapter_description = frontmatter["description"] || chapters[current_index]&.dig(:description)
      @chapter_slug = slug
      @prev_chapter = current_index && current_index > 0 ? chapters[current_index - 1] : nil
      @next_chapter = current_index && current_index < chapters.length - 1 ? chapters[current_index + 1] : nil
    else
      render plain: "Contenuto non trovato per #{slug}", status: :not_found
    end
  end

  private

  def extract_frontmatter(text)
    match = text.match(/\A---\n(.*?)\n---\n/m)
    return [{}, text] unless match

    frontmatter = YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
    body = text.sub(/\A---\n(.*?)\n---\n/m, "")
    [frontmatter, body]
  rescue StandardError
    [{}, text]
  end

  def find_book_file(dir, safe_slug_base)
    # Try exact match
    file_path = dir.join("#{safe_slug_base}.md")
    return file_path if File.exist?(file_path)

    # Try finding a file including the slug (e.g. "047-#{slug}.md")
    match = Dir.glob(dir.join("*#{safe_slug_base}.md")).first
    return match if match

    # Fall back to matching frontmatter slug
    Dir.glob(dir.join("*.md")).each do |path|
      text = File.read(path)
      fm = text.match(/\A---\n(.*?)\n---\n/m)
      next unless fm
      front = YAML.safe_load(fm[1], permitted_classes: [], aliases: false) || {}
      slug = front["slug"].to_s.sub(/\.md\z/, "")
      return path if slug == safe_slug_base
    rescue StandardError
      next
    end

    nil
  end

  def normalize_access(value)
    value.to_s.strip.downcase.presence || "draft"
  end

  def access_blocked?(access)
    return false if Current.user&.superadmin? && Current.user.superadmin_mode_active?
    return true if access == "hidden"

    case access
    when "draft"
      true
    when "free"
      false
    when "registered", "reg_hide"
      !authenticated?
    when "payment", "pay_hide"
      !paid_access?
    else
      true
    end
  end

  def access_visible_in_index?(access)
    return true if Current.user&.superadmin? && Current.user.superadmin_mode_active?
    return false if access == "hidden"

    case access
    when "free"
      true
    when "draft"
      true
    when "registered"
      true
    when "reg_hide"
      authenticated?
    when "payment"
      true
    when "pay_hide"
      paid_access?
    else
      false
    end
  end

  def paid_access?
    service = Service.find_by(slug: BOOK_ONLINE_SERVICE_SLUG)
    return false unless service

    lead = Current.user&.lead
    return false unless lead

    lead.enrollments.where(service_id: service.id, status: %i[confirmed completed]).exists?
  end
end
