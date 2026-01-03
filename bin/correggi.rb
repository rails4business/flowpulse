#!/usr/bin/env ruby
# frozen_string_literal: true
##  pandoc config/data/book_build/il-corpo-un-mondo-da-scoprire.md \
# -o config/data/book_build/il-corpo-un-mondo-da-scoprire.docx
# 
PATH = "config/data/book_build/il-corpo-un-mondo-da-scoprire.md"
BACKUP = PATH.sub(/\.md$/, ".md.bak")

abort "❌ File non trovato: #{PATH}" unless File.exist?(PATH)

content = File.read(PATH)

# Backup di sicurezza
File.write(BACKUP, content)

lines = content.lines
fixed = []
changes = 0

lines.each_with_index do |line, i|
  if line.strip == "---"
    fixed << "***\n"
    changes += 1
  else
    fixed << line
  end
end

File.write(PATH, fixed.join)

puts "✅ Correzione completata"
puts "📄 File: #{PATH}"
puts "🛟 Backup: #{BACKUP}"
puts "✂️ Linee corrette: #{changes}"

if changes.zero?
  puts "✨ Nessun '---' trovato. File già pulito."
else
  puts "💡 Tutti i separatori '---' sono stati convertiti in '***' (Pandoc-safe)"
end
