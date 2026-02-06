#!/usr/bin/env ruby
# sync_book_index.rb
#
# Uso:
#   ruby sync_book_index.rb path/book_index.yml path/book_official_dir [--write]
#
# Esempio:
#   ruby sync_book_index.rb config/data/book_index.yml config/data/book_official
#   ruby sync_book_index.rb config/data/book_index.yml config/data/book_official --write
#
# Cosa fa:
# - Legge book_index.yml (array di voci con header/title/description/slug/color)
# - Scansiona la cartella book_official per file .md
# - Estrae il front matter YAML da ogni .md (--- ... ---)
# - Ordina i file per prefisso numerico (001-, 002-, ...)
# - Confronta conteggi e slugs (ordine incluso)
# - Se --write: riscrive book_index.yml usando i dati dei .md (con backup)

# ruby sync_book_index.rb ../config/data/book_index.yml ../config/data/book_official

# 2) se il report è ok e vuoi aggiornare davvero
# ruby sync_book_index.rb ../config/data/book_index.yml ../config/data/book_official --write

#!/usr/bin/env ruby
# sync_book_index.rb
#
# Uso:
#   ruby sync_book_index.rb path/book_index.yml path/book_official_dir [--write]
#
# Regole:
# - Fonte di verità = file .md in book_official_dir
# - Ordine = prefisso numerico 001-, 002-, ...
# - header = SOLO dal nome file:
#     se basename matcha /^\d+[-_]parte[-_]/ => header true
#     altrimenti => header false
# - --write riscrive book_index.yml (con backup), NON modifica mai i .md

require "yaml"
require "fileutils"

STDOUT.sync = true

def die(msg, code: 1)
  puts "ERRORE: #{msg}"
  exit code
end

def read_text(path)
  File.read(path, mode: "r:BOM|UTF-8")
end

def parse_front_matter(md_text, file:)
  if md_text =~ /\A---\s*\n(.*?)\n---\s*\n/m
    fm = Regexp.last_match(1)
    begin
      data = YAML.safe_load(fm, permitted_classes: [], permitted_symbols: [], aliases: true) || {}
      return data.is_a?(Hash) ? data : {}
    rescue Psych::SyntaxError => e
      die("Front matter YAML non valido in #{file}:\n#{e.message}")
    end
  end
  {}
end

def md_files_sorted(dir)
  files = Dir.glob(File.join(dir, "**", "*.md")).select { |p| File.file?(p) }

  files.sort_by do |path|
    base = File.basename(path)
    if base =~ /\A(\d+)[-_]/
      [0, Regexp.last_match(1).to_i, base]
    else
      [1, 9_999_999, base]
    end
  end
end

# header SOLO dal nome file: 0XX-parte-... => true
def header_from_filename(path)
  base = File.basename(path).downcase
  !!(base =~ /\A\d+[-_]parte[-_]/)
end

def normalize_entry_hash(h, forced_header: nil)
  {
    "header" => forced_header.nil? ? (h["header"] == true) : forced_header,
    "number" => (h["number"] || "").to_s.strip,
    "type" => (h["type"] || "").to_s.strip,
    "title" => (h["title"] || "").to_s.strip,
    "description" => (h["description"] || "").to_s.strip,
    "slug" => (h["slug"] || "").to_s.strip,
    "color" => (h["color"] || "").to_s.strip,
  }
end

def extract_entries_from_md(dir)
  entries = []
  missing_front = []
  missing_fields = []

  md_files_sorted(dir).each do |file|
    text = read_text(file)
    fm = parse_front_matter(text, file: file)

    if fm.empty?
      missing_front << file
      next
    end

    forced_header = header_from_filename(file)
    e = normalize_entry_hash(fm, forced_header: forced_header)
    e["number"] = number_from_filename(file)
    e["type"] = type_from_entry(e)

    req = %w[title slug]
    bad = req.select { |k| e[k].nil? || e[k].empty? }
    missing_fields << [file, bad] if bad.any?

    entries << e
  end

  [entries, missing_front, missing_fields]
end

def load_book_index(path)
  begin
    data = YAML.load_file(path)
  rescue Psych::SyntaxError => e
    die("Sintassi YAML non valida in #{path}:\n#{e.message}")
  end
  die("Formato inatteso: #{path} deve essere un Array di voci YAML (inizia con '-')") unless data.is_a?(Array)
  data.select { |x| x.is_a?(Hash) }.map { |h| normalize_entry_hash(h) }
end

def file_preamble_before_list(yml_text)
  idx = yml_text.index(/^\s*-\s+/)
  return "" if idx.nil?
  yml_text[0...idx].rstrip + "\n\n"
end

def yaml_for_entries(entries)
  out = +""
  entries.each do |e|
    out << "- header: #{e["header"] ? "true" : "false"}\n"
    out << "  number: #{e["number"].inspect}\n" if e["number"].to_s.strip != ""
    out << "  type: #{e["type"].inspect}\n" if e["type"].to_s.strip != ""
    out << "  title: #{e["title"].inspect}\n"
    out << "  description: #{e["description"].inspect}\n"
    out << "  slug: #{e["slug"].inspect}\n"
    out << "  color: #{e["color"].inspect}\n\n"
  end
  out.rstrip + "\n"
end

def number_from_filename(path)
  base = File.basename(path)
  if base =~ /\A(\d+)[-_]/
    Regexp.last_match(1).rjust(3, "0")
  else
    ""
  end
end

def type_from_entry(entry)
  return entry["type"] if entry["type"].to_s.strip != ""
  entry["header"] ? "section header" : "chapter"
end

def slug_dupes(entries)
  counts = Hash.new(0)
  entries.each { |e| counts[e["slug"]] += 1 unless e["slug"].empty? }
  counts.select { |_, c| c > 1 }
end

# ---- main ----

index_path = ARGV[0].to_s.strip
official_dir = ARGV[1].to_s.strip
write = ARGV.include?("--write")

die("Uso: ruby #{File.basename(__FILE__)} path/book_index.yml path/book_official_dir [--write]") if index_path.empty? || official_dir.empty?
die("File non trovato: #{index_path}") unless File.exist?(index_path)
die("Cartella non trovata: #{official_dir}") unless Dir.exist?(official_dir)

puts "== Sync book_index.yml <-> book_official =="
puts "Index:    #{index_path}"
puts "Official: #{official_dir}"
puts "Mode:     #{write ? "WRITE (aggiorna index da .md)" : "DRY RUN (solo confronto)"}"
puts "Source of truth: .md (l'index non modifica mai i file .md)"
puts

index_entries = load_book_index(index_path)
md_entries, missing_front, missing_fields = extract_entries_from_md(official_dir)

puts "Voci in book_index.yml: #{index_entries.size}"
puts "Voci con front matter in book_official: #{md_entries.size}"

if missing_front.any?
  puts
  puts "⚠️  File .md senza front matter (--- ... ---) -> NON conteggiati:"
  missing_front.each { |f| puts "  - #{f}" }
end

if missing_fields.any?
  puts
  puts "⚠️  File .md con campi obbligatori mancanti:"
  missing_fields.each do |file, bad|
    puts "  - #{file} (manca: #{bad.join(", ")})"
  end
end

dupes = slug_dupes(md_entries)
if dupes.any?
  puts
  puts "❌ Slug duplicati nei .md (da correggere prima di aggiornare):"
  dupes.each { |slug, c| puts "  - #{slug} (#{c} volte)" }
  exit 2
end

puts

index_slugs = index_entries.map { |e| e["slug"] }
md_slugs = md_entries.map { |e| e["slug"] }

if index_entries.size != md_entries.size
  puts "⚠️  Conteggio diverso: index=#{index_entries.size} vs md=#{md_entries.size}"
end

diff_found = false

max = [index_slugs.size, md_slugs.size].max
(0...max).each do |i|
  a = index_slugs[i]
  b = md_slugs[i]
  next if a == b

  diff_found = true
  puts "DIFF @#{i + 1}:"
  puts "  index: #{a.inspect}"
  puts "  md:    #{b.inspect}"
  puts
end

only_in_index = index_slugs - md_slugs
only_in_md = md_slugs - index_slugs

if only_in_index.any?
  diff_found = true
  puts "Slug presenti in index ma non nei .md:"
  only_in_index.each { |s| puts "  - #{s}" }
  puts
end

if only_in_md.any?
  diff_found = true
  puts "Slug presenti nei .md ma non in index:"
  only_in_md.each { |s| puts "  - #{s}" }
  puts
end

if !diff_found
  puts "✅ OK: slugs e ordine combaciano (secondo i dati disponibili)."
else
  puts "⚠️  Differenze trovate tra index e .md (vedi sopra)."
end

if write
  yml_text = read_text(index_path)
  preamble = file_preamble_before_list(yml_text)

  new_body = yaml_for_entries(md_entries) # header già calcolato dai nomi file
  new_text = preamble + new_body

  backup_path = index_path + ".bak"
  FileUtils.cp(index_path, backup_path)
  File.write(index_path, new_text)

  puts
  puts "✅ Aggiornato (MD → index): #{index_path}"
  puts "🧷 Backup:               #{backup_path}"
end
