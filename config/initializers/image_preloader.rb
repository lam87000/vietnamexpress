# Initializer pour pré-charger les images au démarrage du serveur
Rails.application.config.after_initialize do
  # Ne pré-charger qu'en production ou si explicitement demandé
  if Rails.env.production? || ENV['PRELOAD_IMAGES'] == 'true'
    
    Rails.logger.info "🚀 Pré-chargement des images au démarrage..."
    
    begin
      # Pré-charger toutes les images des plats
      image_paths = []
      
      Plat.where.not(image_url: [nil, '']).find_each do |plat|
        next if plat.image_url.match?(/^https?:\/\//) # Skip les URLs externes
        
        image_path = Rails.root.join('app/assets/images', plat.image_url)
        if File.exist?(image_path)
          # Lire l'image en mémoire (mise en cache automatique)
          File.read(image_path)
          image_paths << plat.image_url
        end
      end
      
      Rails.logger.info "✅ #{image_paths.count} images pré-chargées en mémoire"
      Rails.logger.info "📁 Images: #{image_paths.join(', ')}"
      
    rescue => e
      Rails.logger.error "❌ Erreur pré-chargement images: #{e.message}"
    end
    
  else
    Rails.logger.info "ℹ️  Pré-chargement images désactivé en développement"
    Rails.logger.info "   Pour activer: PRELOAD_IMAGES=true rails server"
  end
end