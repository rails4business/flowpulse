#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "open3"

INPUT_DIR  = ARGV[0] || "../config/data/book_official"
OUT_DIR    = ARGV[1] || "../config/data/book_build"
BASENAME   = ARGV[2] || "il-corpo-un-mondo-da-scoprire"

def die(msg)
  warn "❌ #{msg}"
  exit 1
end

def run!(cmd)
  stdout, stderr, status = Open3.capture3(cmd)
  die("Comando fallito:\n#{cmd}\n\n#{stderr.empty? ? stdout : stderr}") unless status.success?
  stdout
end

def pandoc_available?
  system("pandoc -v > /dev/null 2>&1")
end

def strip_front_matter(md)
  # Rimuove YAML front matter: --- ... ---
  # solo se è all'inizio del file.
  md.sub(/\A---\s*\n.*?\n---\s*\n/m, "")
end

def numeric_prefix(path)
  base = File.basename(path)
  m = base.match(/\A(\d+)[-_]/)
  m ? m[1].to_i : 1_000_000
end

die("Cartella input non trovata: #{INPUT_DIR}") unless Dir.exist?(INPUT_DIR)
die("Pandoc non trovato. Installa con: brew install pandoc") unless pandoc_available?

FileUtils.mkdir_p(OUT_DIR)

md_files = Dir.glob(File.join(INPUT_DIR, "**", "*.md"))
die("Nessun .md trovato in #{INPUT_DIR}") if md_files.empty?

# Ordina: prima chi ha prefisso numerico (001-...), poi per percorso
md_files.sort_by! { |p| [numeric_prefix(p), p.downcase] }

merged_md_path  = File.join(OUT_DIR, "#{BASENAME}.md")
merged_docx_path = File.join(OUT_DIR, "#{BASENAME}.docx")

# Costruisci un unico MD con separatori e titoli di sezione opzionali
merged = +""
md_files.each do |path|
  content = File.read(path, encoding: "UTF-8")
  content = strip_front_matter(content).strip

  next if content.empty?

  # Separatore pagina + commento sorgente (utile per debug, non rompe Docs)
  merged << "\n\n\\newpage\n\n"
  merged << "<!-- SOURCE: #{path} -->\n\n"
  merged << content
  merged << "\n"
end

File.write(merged_md_path, merged)

# Converti in DOCX
# --from markdown+smart per una resa un filo migliore
run!(%Q(pandoc "#{merged_md_path}"  --from=markdown+smart-yaml_metadata_block --to=docx -o "#{merged_docx_path}"))

puts "✅ Creato:"
puts " - #{merged_md_path}"
puts " - #{merged_docx_path}"
puts
puts "Apri il .docx con Google Docs per mantenere la formattazione."
