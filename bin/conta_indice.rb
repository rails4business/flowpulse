#!/usr/bin/env ruby
# conta_indice.rb
# Uso:
#   ruby conta_indice.rb config/data/book_index.yml

require "yaml"

STDOUT.sync = true

puts "== book_index counter =="
puts "ARGV: #{ARGV.inspect}"

path = ARGV[0].to_s.strip
if path.empty?
  puts "ERRORE: manca il path del file YAML."
  puts "Uso: ruby #{File.basename(__FILE__)} path/al/file.yml"
  exit 1
end

unless File.exist?(path)
  puts "ERRORE: file non trovato: #{path}"
  exit 1
end

data = nil
begin
  data = YAML.load_file(path)
rescue Psych::SyntaxError => e
  puts "ERRORE: sintassi YAML non valida in #{path}"
  puts e.message
  exit 1
rescue => e
  puts "ERRORE: impossibile leggere/parsing #{path} (#{e.class})"
  puts e.message
  exit 1
end

unless data.is_a?(Array)
  puts "ERRORE: formato inatteso. Mi aspettavo un Array di voci YAML (inizia con '-')."
  puts "Trovato: #{data.class} => #{data.inspect[0, 200]}..."
  exit 1
end

entries = data.select { |x| x.is_a?(Hash) }

total = entries.size
headers = entries.count { |e| e["header"] == true }
chapters = entries.count { |e| e["header"] == false }
unknown_header = entries.count { |e| ![true, false].include?(e["header"]) }

slugs = entries.map { |e| e["slug"] }.compact.map { |s| s.to_s.strip }.reject(&:empty?)
missing_slug = entries.count { |e| e["slug"].nil? || e["slug"].to_s.strip.empty? }

slug_counts = slugs.each_with_object(Hash.new(0)) { |s, h| h[s] += 1 }
dup_slugs = slug_counts.select { |_, c| c > 1 }

colors = entries.map { |e| e["color"] }.compact.map { |c| c.to_s.strip }.reject(&:empty?)
color_counts = colors.each_with_object(Hash.new(0)) { |c, h| h[c] += 1 }

missing_title = entries.count { |e| e["title"].nil? || e["title"].to_s.strip.empty? }

puts
puts "File: #{path}"
puts "-" * 60
puts "Totale voci:             #{total}"
puts "Header (sezioni):        #{headers}"
puts "Capitoli (header=false): #{chapters}"
puts "Header non validi:       #{unknown_header}"
puts "Titoli mancanti/vuoti:   #{missing_title}"
puts "Slug mancanti/vuoti:     #{missing_slug}"
puts "-" * 60

if dup_slugs.any?
  puts "⚠️  Slug duplicati:"
  dup_slugs.sort_by { |slug, _| slug }.each do |slug, count|
    puts "  - #{slug} (#{count} volte)"
  end
else
  puts "✅ Nessuno slug duplicato."
end

puts "-" * 60
puts "Distribuzione per color:"
color_counts.sort_by { |color, _| color }.each do |color, count|
  puts "  - #{color.ljust(14)} #{count}"
end
puts "-" * 60

exit((missing_slug > 0 || dup_slugs.any? || unknown_header > 0) ? 2 : 0)
