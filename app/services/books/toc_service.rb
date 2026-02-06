module Books
  class TocService
    YAML_PATH = Rails.root.join("config", "data", "book_index.yml")
    MD_DIR = Rails.root.join("config", "data", "book_official")

    def call
      return [] unless File.exist?(YAML_PATH)

      counter = 0
      access_map = access_by_slug

      YAML.load_file(YAML_PATH).map do |item|
        is_header = item["header"]
        chapter_num = nil
        
        unless is_header
          counter += 1
          chapter_num = counter
        end

        {
          title: item["title"],
          slug: item["slug"],
          type: item["type"],
          header: is_header,
          description: item["description"],
          color: item["color"],
          access: access_map[normalize_slug(item["slug"])] || "draft",
          chapter_number: chapter_num
        }
      end
    end

    private

    def access_by_slug
      return {} unless Dir.exist?(MD_DIR)

      map = {}
      Dir.glob(MD_DIR.join("*.md")).each do |path|
        text = File.read(path)
        match = text.match(/\A---\n(.*?)\n---\n/m)
        next unless match

        frontmatter = YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
        slug = normalize_slug(frontmatter["slug"])
        access = frontmatter["access"].to_s.strip.downcase
        map[slug] = access if slug.present?
      rescue StandardError
        next
      end
      map
    end

    def normalize_slug(value)
      value.to_s.sub(/\.md\z/, "")
    end
  end
end
