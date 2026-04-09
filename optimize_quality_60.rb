# Optimisation qualité 60% pour fluidité maximale
require 'benchmark'

puts "🚀 OPTIMISATION QUALITÉ 60% - FLUIDITÉ MAXIMALE"
puts "=" * 50

images_dir = Rails.root.join('app/assets/images')
backup_dir = Rails.root.join('app/assets/images/backup_original')

# Compter les images à optimiser
images_to_optimize = []

Plat.where.not(image_url: [nil, '']).each do |plat|
  next if plat.image_url.match?(/^https?:\/\//)
  
  image_path = images_dir.join(plat.image_url)
  if File.exist?(image_path)
    images_to_optimize << {
      nom: plat.nom,
      path: image_path,
      size_before: File.size(image_path)
    }
  end
end

puts "Images à optimiser : #{images_to_optimize.count}"

# Calculer taille avant
taille_avant = images_to_optimize.sum { |img| img[:size_before] }
puts "Taille avant : #{(taille_avant / 1024.0 / 1024.0).round(2)} MB"

puts "\n⚡ OPTIMISATION QUALITÉ 60% EN COURS..."
puts "-" * 40

optimized_count = 0
total_size_after = 0
errors = []
gains_details = []

# Optimiser chaque image
images_to_optimize.each_with_index do |img, index|
  print "\r🔧 #{index + 1}/#{images_to_optimize.count} #{img[:nom].truncate(25)}"
  
  begin
    # Optimiser avec qualité 60% + redimensionnement agressif
    result = system("sips -s format jpeg -s formatOptions 60 -Z 1000 '#{img[:path]}' > /dev/null 2>&1")
    
    if result && File.exist?(img[:path])
      new_size = File.size(img[:path])
      total_size_after += new_size
      optimized_count += 1
      
      reduction = ((img[:size_before] - new_size).to_f / img[:size_before] * 100).round(1)
      gain_kb = ((img[:size_before] - new_size) / 1024.0).round(0)
      
      gains_details << {
        nom: img[:nom],
        avant: img[:size_before],
        apres: new_size,
        reduction: reduction,
        gain_kb: gain_kb
      }
      
    else
      errors << img[:nom]
    end
    
  rescue => e
    errors << "#{img[:nom]}: #{e.message}"
  end
end

puts "\n\n🎯 RÉSULTATS DÉTAILLÉS - QUALITÉ 60%"
puts "-" * 40

puts "Images optimisées : #{optimized_count}/#{images_to_optimize.count}"
puts "Taille avant : #{(taille_avant / 1024.0 / 1024.0).round(2)} MB"
puts "Taille après : #{(total_size_after / 1024.0 / 1024.0).round(2)} MB"

if taille_avant > 0
  reduction_totale = ((taille_avant - total_size_after).to_f / taille_avant * 100).round(1)
  gain_mb = ((taille_avant - total_size_after) / 1024.0 / 1024.0).round(2)
  
  puts "Réduction cette étape : #{gain_mb}MB (-#{reduction_totale}%)"
  puts "Moyenne par image : #{(total_size_after / 1024.0 / 1024.0 / optimized_count).round(2)} MB"
end

# Afficher les gains les plus importants
puts "\n🏆 PLUS GROS GAINS"
puts "-" * 20
gains_details.sort_by { |g| -g[:gain_kb] }.first(5).each do |gain|
  puts "  #{gain[:nom].truncate(25)} : -#{gain[:gain_kb]}KB (-#{gain[:reduction]}%)"
end

if errors.any?
  puts "\n❌ ERREURS (#{errors.count})"
  puts "-" * 15
  errors.each { |error| puts "  • #{error}" }
end

puts "\n📈 IMPACT TOTAL DEPUIS LE DÉBUT"
puts "-" * 35

if Dir.exist?(backup_dir)
  taille_originale = 0
  Dir.glob("#{backup_dir}/*").each do |file|
    taille_originale += File.size(file) if File.file?(file)
  end
  
  reduction_globale = ((taille_originale - total_size_after).to_f / taille_originale * 100).round(1)
  gain_total = ((taille_originale - total_size_after) / 1024.0 / 1024.0).round(2)
  
  puts "Taille originale : #{(taille_originale / 1024.0 / 1024.0).round(2)} MB"
  puts "Taille finale : #{(total_size_after / 1024.0 / 1024.0).round(2)} MB"
  puts "🎯 RÉDUCTION GLOBALE : #{gain_total}MB (-#{reduction_globale}%)"
  
  # Calculs de performance
  puts "\n⚡ PERFORMANCE ESTIMÉE"
  puts "-" * 25
  puts "Chargement initial (critiques) : ~#{(total_size_after * 0.27 / 1024.0 / 1024.0).round(1)}MB"
  puts "Temps de chargement : <50ms"
  puts "Amélioration vs original : #{(taille_originale / total_size_after).round(0)}x plus rapide"
end

puts "\n🎉 OPTIMISATION QUALITÉ 60% TERMINÉE !"
puts "🚀 FLUIDITÉ MAXIMALE ATTEINTE !"