# Test d'optimisation de qualité plus agressive
require 'benchmark'

puts "🎯 TEST OPTIMISATION QUALITÉ AGRESSIVE"
puts "=" * 50

images_dir = Rails.root.join('app/assets/images')
backup_dir = Rails.root.join('app/assets/images/backup_original')

# Calculer la taille actuelle
taille_actuelle = 0
images_count = 0

Plat.where.not(image_url: [nil, '']).each do |plat|
  next if plat.image_url.match?(/^https?:\/\//)
  
  image_path = images_dir.join(plat.image_url)
  if File.exist?(image_path)
    taille_actuelle += File.size(image_path)
    images_count += 1
  end
end

puts "\n📊 ÉTAT ACTUEL"
puts "-" * 20
puts "Images : #{images_count}"
puts "Taille actuelle : #{(taille_actuelle / 1024.0 / 1024.0).round(2)} MB"
puts "Moyenne actuelle : #{(taille_actuelle / 1024.0 / 1024.0 / images_count).round(2)} MB par image"

# Test avec différentes qualités
qualites = [70, 65, 60, 55]

qualites.each do |qualite|
  puts "\n🔍 TEST QUALITÉ #{qualite}%"
  puts "-" * 25
  
  taille_simulee = 0
  sample_count = 0
  
  # Tester sur un échantillon de 3 images pour estimer
  Plat.where.not(image_url: [nil, '']).limit(3).each do |plat|
    next if plat.image_url.match?(/^https?:\/\//)
    
    image_path = images_dir.join(plat.image_url)
    next unless File.exist?(image_path)
    
    # Créer fichier temporaire pour test
    temp_file = "/tmp/test_#{qualite}_#{File.basename(plat.image_url, '.*')}.jpg"
    
    # Optimiser avec sips
    system("sips -s format jpeg -s formatOptions #{qualite} -Z 1200 '#{image_path}' --out '#{temp_file}' > /dev/null 2>&1")
    
    if File.exist?(temp_file)
      taille_test = File.size(temp_file)
      taille_simulee += taille_test
      sample_count += 1
      
      File.delete(temp_file)
    end
  end
  
  if sample_count > 0
    # Extrapoler pour toutes les images
    moyenne_echantillon = taille_simulee / sample_count
    taille_totale_estimee = moyenne_echantillon * images_count
    
    reduction = ((taille_actuelle - taille_totale_estimee).to_f / taille_actuelle * 100).round(1)
    
    puts "  Taille estimée : #{(taille_totale_estimee / 1024.0 / 1024.0).round(2)} MB"
    puts "  Réduction supplémentaire : -#{reduction}%"
    puts "  Taille moyenne : #{(taille_totale_estimee / 1024.0 / 1024.0 / images_count).round(2)} MB par image"
    
    # Évaluation de la qualité
    if qualite >= 65
      puts "  💚 Qualité : Excellente (recommandé)"
    elsif qualite >= 60
      puts "  💛 Qualité : Bonne (acceptable)"
    else
      puts "  🟠 Qualité : Correcte (limite)"
    end
  end
end

puts "\n🎯 RECOMMANDATIONS"
puts "-" * 20
puts "• Qualité 70% : Optimal qualité/performance"
puts "• Qualité 65% : Bon compromis pour mobile"
puts "• Qualité 60% : Maximum recommandé"

puts "\n💡 BÉNÉFICES ATTENDUS"
puts "-" * 20
puts "• Temps de chargement encore réduit"
puts "• Moins de bande passante sur Render"
puts "• Meilleure expérience mobile"
puts "• Coûts de hosting réduits"

puts "\n🚀 PROCHAINE ÉTAPE"
puts "-" * 20
puts "Choisir une qualité et exécuter l'optimisation ?"