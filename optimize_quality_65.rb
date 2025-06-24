# Optimisation qualité 65% pour gain supplémentaire
require 'benchmark'

puts "🚀 OPTIMISATION QUALITÉ 65%"
puts "=" * 40

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

puts "\n⚡ OPTIMISATION EN COURS..."
puts "-" * 30

optimized_count = 0
total_size_after = 0
errors = []

# Optimiser chaque image
images_to_optimize.each_with_index do |img, index|
  print "\r#{index + 1}/#{images_to_optimize.count} "
  
  begin
    # Optimiser avec qualité 65%
    result = system("sips -s format jpeg -s formatOptions 65 -Z 1200 '#{img[:path]}' > /dev/null 2>&1")
    
    if result && File.exist?(img[:path])
      new_size = File.size(img[:path])
      total_size_after += new_size
      optimized_count += 1
      
      reduction = ((img[:size_before] - new_size).to_f / img[:size_before] * 100).round(1)
      if reduction > 20
        print "✅ #{img[:nom].truncate(20)} (-#{reduction}%) "
      end
    else
      errors << img[:nom]
    end
    
  rescue => e
    errors << "#{img[:nom]}: #{e.message}"
  end
end

puts "\n\n🎯 RÉSULTATS FINAUX"
puts "-" * 25

puts "Images optimisées : #{optimized_count}/#{images_to_optimize.count}"
puts "Taille avant : #{(taille_avant / 1024.0 / 1024.0).round(2)} MB"
puts "Taille après : #{(total_size_after / 1024.0 / 1024.0).round(2)} MB"

if taille_avant > 0
  reduction_totale = ((taille_avant - total_size_after).to_f / taille_avant * 100).round(1)
  gain_mb = ((taille_avant - total_size_after) / 1024.0 / 1024.0).round(2)
  
  puts "Réduction : #{gain_mb}MB (-#{reduction_totale}%)"
  puts "Moyenne par image : #{(total_size_after / 1024.0 / 1024.0 / optimized_count).round(2)} MB"
end

if errors.any?
  puts "\n❌ ERREURS (#{errors.count})"
  puts "-" * 15
  errors.each { |error| puts "  • #{error}" }
end

puts "\n🎉 OPTIMISATION TERMINÉE !"
puts "🚀 Site encore plus rapide !"

# Impact global depuis le début
puts "\n📈 IMPACT TOTAL DEPUIS LE DÉBUT"
puts "-" * 35

if Dir.exist?(backup_dir)
  taille_originale = 0
  Dir.glob("#{backup_dir}/*").each do |file|
    taille_originale += File.size(file) if File.file?(file)
  end
  
  reduction_globale = ((taille_originale - total_size_after).to_f / taille_originale * 100).round(1)
  puts "Taille originale : #{(taille_originale / 1024.0 / 1024.0).round(2)} MB"
  puts "Taille finale : #{(total_size_after / 1024.0 / 1024.0).round(2)} MB"
  puts "🎯 RÉDUCTION GLOBALE : -#{reduction_globale}%"
end