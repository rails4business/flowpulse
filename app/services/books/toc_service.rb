module Books
  class TocService
    DEFAULT_FOLDER = "posturacorretta_il_corpo_un_mondo_da_scoprire"
    DEFAULT_INDEX_FILE = "posturacorretta_il_corpo_un_mondo_da_scoprire.yml"

    def initialize(yaml_path: nil, md_dir: nil)
      @yaml_path = yaml_path || Rails.root.join("config", "data", "books", DEFAULT_FOLDER, DEFAULT_INDEX_FILE)
      @md_dir = md_dir || Rails.root.join("config", "data", "books", DEFAULT_FOLDER)
    end

    def call
      return [] unless File.exist?(@yaml_path)

      counter = 0
      access_map = access_by_slug

      YAML.load_file(@yaml_path).map do |item|
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
      return {} unless Dir.exist?(@md_dir)

      map = {}
      Dir.glob(@md_dir.join("*.md")).each do |path|
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
