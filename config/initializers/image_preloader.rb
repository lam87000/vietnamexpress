# Initializer pour pré-charger les images au démarrage du serveur
Rails.application.config.after_initialize do
  # Ne pré-charger qu'en production ou si explicitement demandé
  # ET seulement si on n'est pas en phase de build ou dans un contexte sans DB
  should_preload = (Rails.env.production? || ENV['PRELOAD_IMAGES'] == 'true') && 
                   !defined?(Rails::Console) && 
                   !File.basename($0).in?(['rake', 'rails']) &&
                   ENV['RAILS_ENV'] != 'assets' &&
                   !ENV.key?('ASSETS_PRECOMPILE') &&
                   ENV['DATABASE_URL'].present?
  
  if should_preload
    
    Rails.logger.info "🚀 Pré-chargement des images au démarrage..."
    
    db_connection_errors = [ActiveRecord::ConnectionNotEstablished]
    db_connection_errors << PG::ConnectionBad if defined?(PG::ConnectionBad)

    begin
      # Vérifier que la base de données est disponible
      ActiveRecord::Base.connection.execute("SELECT 1")
      
      # Vérifier que la table existe avant de l'utiliser
      unless ActiveRecord::Base.connection.table_exists?('plats')
        Rails.logger.warn "⚠️  Table 'plats' n'existe pas encore, pré-chargement ignoré"
        return
      end
      
      # Pré-charger toutes les images des plats
      image_paths = []
      
      Plat.where.not(image_url: [nil, '']).find_each do |plat|
        next if plat.image_url.match?(/^https?:\/\//) # Skip les URLs externes
        
        # Vérifier les chemins possibles pour les images
        possible_paths = [
          Rails.root.join('app/assets/images', plat.image_url),
          Rails.root.join('public/assets', plat.image_url),
          Rails.root.join('public/images', plat.image_url)
        ]
        
        image_found = false
        possible_paths.each do |image_path|
          if File.exist?(image_path)
            # Lire l'image en mémoire (mise en cache automatique)
            File.read(image_path)
            image_paths << plat.image_url
            image_found = true
            break
          end
        end
        
        unless image_found
          Rails.logger.debug "🔍 Image non trouvée: #{plat.image_url}"
        end
      end
      
      Rails.logger.info "✅ #{image_paths.count} images pré-chargées en mémoire"
      if image_paths.any?
        Rails.logger.info "📁 Images: #{image_paths.first(5).join(', ')}#{image_paths.count > 5 ? '...' : ''}"
      end
      
    rescue *db_connection_errors => e
      Rails.logger.warn "⚠️  Base de données pas encore disponible: #{e.message.split("\n").first}"
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn "⚠️  Base de données pas encore prête: #{e.message}"
    rescue => e
      Rails.logger.error "❌ Erreur pré-chargement images: #{e.message}"
      Rails.logger.error "📍 Backtrace: #{e.backtrace.first(3).join(', ')}" if Rails.env.development?
    end
    
  else
    Rails.logger.info "ℹ️  Pré-chargement images désactivé en développement"
    Rails.logger.info "   Pour activer: PRELOAD_IMAGES=true rails server"
  end
end
