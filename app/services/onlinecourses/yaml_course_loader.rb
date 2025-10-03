# frozen_string_literal: true

require "yaml"
require "ostruct"

module Onlinecourses
  class YamlCourseLoader
    def self.load_from_item(item)
      data   = item.data.presence || load_yaml_from_disk(item)
      course = (data["course"] || {})

      OpenStruct.new(
        content_slug:   (course["content_slug"].presence || item.slug),
        title:          (course["titolo"].presence || course["title"].presence || item.title.presence || item.slug.humanize),
        description:    (course["description"].to_s),
        cover_url:      (course["url_copertina"].to_s.presence),
        preparatory_courses: normalize_preparatory(course.dig("online", "preparatory_courses")),
        lessons:        normalize_lessons(course.dig("online", "lessons"))
      )
    rescue => e
      Rails.logger.error("[YamlCourseLoader] item=#{item&.id} #{e.class}: #{e.message}")
      OpenStruct.new(
        content_slug: item&.slug.to_s,
        title:        (item&.title.presence || item&.slug&.humanize || "Corso"),
        description:  item&.summary.to_s,
        cover_url:    nil,
        preparatory_courses: [],
        lessons: []
      )
    end

    # --- helpers identici a prima ---
    def self.load_yaml_from_disk(item)
      rel = item.source_path.presence || item.yml_filename
      return {} unless rel.present?
      base_path = Rails.root.join("data_yml")
      abs = rel.start_with?("/") ? Pathname.new(rel) : base_path.join(rel)
      YAML.safe_load_file(abs.to_s, permitted_classes: [ Date, Time ], aliases: true) || {}
    rescue Errno::ENOENT
      {}
    end

    def self.normalize_preparatory(arr)
      Array(arr).map { |h|
        {
          "slug"        => h["slug"].to_s,
          "title"       => h["title"].to_s,
          "description" => h["description"].is_a?(Array) ? h["description"].join(" ") : h["description"].to_s,
          "shared"      => !!h["shared"]
        }
      }
    end

    def self.normalize_lessons(arr)
      Array(arr).map { |h|
        {
          "slug"         => h["slug"].to_s,
          "type"         => h["type"].to_s,
          "title"        => h["title"].to_s,
          "description"  => h["description"].is_a?(Array) ? h["description"].join(" ") : h["description"].to_s,
          "chapter"      => !!h["chapter"],
          "cover_url"    => h["url_copertina"].to_s,
          "content_slug" => h["content_slug"].to_s,
          "url_pdf"      => h["url_pdf"].to_s,
          "url_video"    => h["url_video"].to_s
        }
      }
    end
  end
end
