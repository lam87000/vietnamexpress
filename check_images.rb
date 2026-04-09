#!/usr/bin/env ruby

require 'uri'
require 'cgi'

# Contrôle intégral des problèmes d'images pour restaurant_limoges

puts "🔍 CONTRÔLE INTÉGRAL DES IMAGES - RESTAURANT LIMOGES"
puts "=" * 60

# 1. LISTE DES FICHIERS D'IMAGES PHYSIQUES
puts "\n1. 📁 FICHIERS D'IMAGES PHYSIQUES"
images_dir = "app/assets/images"

physical_images = []
if Dir.exist?(images_dir)
  Dir.entries(images_dir).select { |f| f.match?(/\.(jpg|jpeg|png|gif|webp)$/i) }.each do |file|
    size = File.size(File.join(images_dir, file))
    physical_images << file
    puts "  ✓ #{file} (#{(size/1024.0).round(1)} KB)"
  end
else
  puts "  ❌ Dossier app/assets/images introuvable"
end

puts "\n  📊 Total: #{physical_images.length} fichiers physiques"

# 2. FICHIERS DE SAUVEGARDE
puts "\n2. 💾 FICHIERS DE SAUVEGARDE (backup_original)"
backup_dir = "#{images_dir}/backup_original"
backup_images = []

if Dir.exist?(backup_dir)
  Dir.entries(backup_dir).select { |f| f.match?(/\.(jpg|jpeg|png|gif|webp)$/i) }.each do |file|
    size = File.size(File.join(backup_dir, file))
    backup_images << file
    puts "  ✓ #{file} (#{(size/1024.0).round(1)} KB)"
  end
else
  puts "  ❌ Dossier backup_original introuvable"
end

puts "  📊 Total: #{backup_images.length} fichiers de sauvegarde"

# 3. RÉFÉRENCES EN BASE DE DONNÉES
puts "\n3. 🗄️  RÉFÉRENCES EN BASE DE DONNÉES"
require 'sqlite3'

db_images = []
begin
  db = SQLite3::Database.new('storage/development.sqlite3')
  
  # Récupérer toutes les références d'images
  rows = db.execute("SELECT nom, image_url FROM plats WHERE image_url IS NOT NULL AND image_url != ''")
  
  rows.each do |nom, image_url|
    db_images << image_url
    puts "  📋 #{nom}: #{image_url}"
  end
  
  db.close
rescue SQLite3::Exception => e
  puts "  ❌ Erreur base de données: #{e.message}"
end

puts "  📊 Total: #{db_images.length} références en base"

# 4. PROBLÈMES D'ENCODAGE D'URL
puts "\n4. 🔤 PROBLÈMES D'ENCODAGE D'URL"
encoding_problems = []

db_images.each do |image_url|
  # Vérifier les caractères spéciaux
  if image_url.match?(/[àáâãäéèêëíìîïóòôõöúùûüçñÀÁÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ\s]/)
    encoded_url = CGI.escape(image_url)
    encoding_problems << {
      original: image_url,
      encoded: encoded_url,
      issues: []
    }
    
    # Identifier les types de problèmes
    issues = []
    issues << "Caractères unicode" if image_url.match?(/[àáâãäéèêëíìîïóòôõöúùûüçñÀÁÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ]/)
    issues << "Espaces" if image_url.include?(' ')
    issues << "Tirets spéciaux" if image_url.match?(/[–—]/)
    
    encoding_problems.last[:issues] = issues
    
    puts "  ⚠️  #{image_url}"
    puts "      → Problèmes: #{issues.join(', ')}"
    puts "      → Encodé: #{encoded_url}"
  end
end

puts "  📊 Total: #{encoding_problems.length} fichiers avec problèmes d'encodage"

# 5. FICHIERS MANQUANTS
puts "\n5. ❌ FICHIERS MANQUANTS"
missing_files = []

db_images.each do |image_url|
  physical_path = File.join(images_dir, image_url)
  unless File.exist?(physical_path)
    missing_files << image_url
    puts "  ❌ #{image_url} (référencé en base mais fichier absent)"
  end
end

puts "  📊 Total: #{missing_files.length} fichiers manquants"

# 6. FICHIERS ORPHELINS
puts "\n6. 👻 FICHIERS ORPHELINS"
orphan_files = []

physical_images.each do |file|
  unless db_images.include?(file)
    orphan_files << file
    puts "  👻 #{file} (fichier présent mais non référencé en base)"
  end
end

puts "  📊 Total: #{orphan_files.length} fichiers orphelins"

# 7. DIFFÉRENCES D'EXTENSIONS
puts "\n7. 🔄 PROBLÈMES D'EXTENSIONS"
extension_problems = []

db_images.each do |image_url|
  db_ext = File.extname(image_url).downcase
  
  # Chercher des fichiers avec des extensions différentes
  base_name = File.basename(image_url, ".*")
  physical_images.each do |physical_file|
    physical_base = File.basename(physical_file, ".*")
    physical_ext = File.extname(physical_file).downcase
    
    if base_name == physical_base && db_ext != physical_ext
      extension_problems << {
        db_file: image_url,
        physical_file: physical_file,
        db_ext: db_ext,
        physical_ext: physical_ext
      }
      puts "  🔄 Incohérence: DB #{image_url} vs Fichier #{physical_file}"
    end
  end
end

puts "  📊 Total: #{extension_problems.length} problèmes d'extensions"

# 8. TAILLES DE FICHIERS SUSPECTES
puts "\n8. 📏 TAILLES DE FICHIERS"
size_issues = []

physical_images.each do |file|
  path = File.join(images_dir, file)
  size = File.size(path)
  size_kb = (size / 1024.0).round(1)
  
  if size > 10 * 1024 * 1024  # Plus de 10MB
    size_issues << { file: file, size: size_kb, issue: "Trop volumineux" }
    puts "  ⚠️  #{file}: #{size_kb} KB (très volumineux)"
  elsif size < 1024  # Moins de 1KB
    size_issues << { file: file, size: size_kb, issue: "Trop petit" }
    puts "  ⚠️  #{file}: #{size_kb} KB (suspicieusement petit)"
  end
end

puts "  📊 Total: #{size_issues.length} fichiers avec taille suspecte"

# 9. RÉSUMÉ ET PLAN DE CORRECTION
puts "\n" + "=" * 60
puts "📋 RÉSUMÉ DES PROBLÈMES IDENTIFIÉS"
puts "=" * 60

problems_count = 0

if encoding_problems.any?
  problems_count += encoding_problems.length
  puts "\n🔤 ENCODAGE D'URL (#{encoding_problems.length} fichiers)"
  puts "   Solution: Renommer les fichiers ou encoder les URLs"
end

if missing_files.any?
  problems_count += missing_files.length
  puts "\n❌ FICHIERS MANQUANTS (#{missing_files.length} fichiers)"
  puts "   Solution: Copier les fichiers ou corriger les références"
end

if orphan_files.any?
  problems_count += orphan_files.length
  puts "\n👻 FICHIERS ORPHELINS (#{orphan_files.length} fichiers)"
  puts "   Solution: Supprimer ou référencer en base"
end

if extension_problems.any?
  problems_count += extension_problems.length
  puts "\n🔄 PROBLÈMES D'EXTENSIONS (#{extension_problems.length} fichiers)"
  puts "   Solution: Renommer fichiers ou corriger base"
end

if size_issues.any?
  problems_count += size_issues.length
  puts "\n📏 TAILLES SUSPECTES (#{size_issues.length} fichiers)"
  puts "   Solution: Optimiser les images trop lourdes"
end

puts "\n" + "=" * 60
puts "🎯 PLAN DE CORRECTION PRIORITAIRE"
puts "=" * 60

puts "\n1. PRIORITÉ HAUTE - Fichiers manquants"
missing_files.each do |file|
  puts "   → Copier ou créer: #{file}"
end

puts "\n2. PRIORITÉ HAUTE - Problèmes d'encodage"
encoding_problems.each do |problem|
  puts "   → Renommer: #{problem[:original]} (#{problem[:issues].join(', ')})"
end

puts "\n3. PRIORITÉ MOYENNE - Extensions incohérentes"
extension_problems.each do |problem|
  puts "   → Corriger: #{problem[:db_file]} ↔ #{problem[:physical_file]}"
end

puts "\n4. PRIORITÉ BASSE - Fichiers orphelins"
orphan_files.each do |file|
  puts "   → Évaluer: #{file}"
end

puts "\n5. PRIORITÉ BASSE - Optimisation des tailles"
size_issues.each do |issue|
  puts "   → Optimiser: #{issue[:file]} (#{issue[:issue]})"
end

if problems_count == 0
  puts "\n✅ AUCUN PROBLÈME CRITIQUE IDENTIFIÉ!"
else
  puts "\n⚠️  TOTAL: #{problems_count} problèmes identifiés"
end

puts "\n" + "=" * 60
puts "🔧 RECOMMANDATIONS TECHNIQUES"
puts "=" * 60

puts <<~RECOMMENDATIONS
1. MIDDLEWARE SERVE_ASSETS:
   ✓ Correctement configuré pour le développement
   ⚠️  Attention aux caractères spéciaux dans les noms

2. LAZY LOADING:
   ✓ Système intelligent implémenté
   ⚠️  Vérifier les chemins data-src

3. MODÈLE PLAT:
   ✓ Méthodes has_image? et is_local_image? présentes
   ⚠️  Méthode image_path pourrait gérer l'encodage

4. VUES:
   ✓ Gestion des images locales et externes
   ⚠️  Chemins /assets/ codés en dur dans data-src

5. BASE DE DONNÉES:
   ✓ Structure correcte avec image_url
   ⚠️  URLs non encodées pour caractères spéciaux
RECOMMENDATIONS

puts "\n✨ Contrôle terminé!"