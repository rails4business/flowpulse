# frozen_string_literal: true

# bin/rails book:generate_md
namespace :book do
  desc "Genera file markdown numerati nella cartella book"
  task generate_md: :environment do
    require "yaml"
    require "fileutils"

    source = Rails.root.join("config/data/book_index.yml")
    target_dir = Rails.root.join("config/data/book")

    FileUtils.mkdir_p(target_dir)

    data = YAML.load_file(source)

    index = 1

    data.each do |item|
      number = index.to_s.rjust(2, "0")
      slug   = item["slug"]
      file   = "#{number}-#{slug}.md"
      path   = target_dir.join(file)

      if File.exist?(path)
        puts "⏭️  Skipping existing file: #{file}"
        index += 1
        next
      end

      content = <<~MD
        ---
        title: "#{item["title"]}"
        description: "#{item["description"]}"
        slug: "#{slug}"
        color: "#{item["color"]}"
        ---

        # #{item["title"]}

      MD

      File.write(path, content)
      puts "✅ Created #{file}"

      index += 1
    end

    puts "📚 Generazione completata (#{index - 1} file)"
  end
end
