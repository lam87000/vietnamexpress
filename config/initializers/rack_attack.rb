# Security: Rate limiting configuration
class Rack::Attack
  # Store in memory (production devrait utiliser Redis)
  cache.store = ActiveSupport::Cache::MemoryStore.new
  
  # PROTECTION COMMANDES: Maximum 3 commandes par IP par heure
  throttle('commandes/ip', limit: 3, period: 1.hour) do |req|
    req.ip if req.path == '/commandes' && req.post?
  end
  
  # PROTECTION EMAIL: Maximum 5 commandes par email par jour
  throttle('commandes/email', limit: 5, period: 1.day) do |req|
    if req.path == '/commandes' && req.post?
      # Extraire l'email des paramètres de la requête
      if req.params['commande'] && req.params['commande']['client_email']
        req.params['commande']['client_email'].downcase.strip
      end
    end
  end
  
  # PROTECTION GLOBALE: Maximum 60 requêtes par IP par minute
  throttle('requests/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end
  
  # PROTECTION PANIER: Maximum 20 ajouts au panier par IP par minute
  throttle('cart/ip', limit: 20, period: 1.minute) do |req|
    req.ip if req.path.include?('add_to_cart')
  end
  
  # Log des attaques détectées
  self.throttled_response = lambda do |env|
    match_data = env['rack.attack.match_data']
    now = match_data[:epoch_time]
    
    Rails.logger.warn "🚨 ATTAQUE DÉTECTÉE: #{env['rack.attack.matched']} - IP: #{env['REMOTE_ADDR']} - Path: #{env['PATH_INFO']}"
    
    headers = {
      'Content-Type' => 'text/plain',
      'Retry-After' => match_data[:period].to_s
    }
    
    body = "🛡️ Limite de sécurité atteinte. Réessayez dans #{match_data[:period]} secondes.\n"
    
    [429, headers, [body]]
  end
  
  # Whitelist des IPs de développement (optionnel)
  safelist('allow-localhost') do |req|
    req.ip == '127.0.0.1' || req.ip == '::1' if Rails.env.development?
  end
end

Rails.logger.info "🛡️ Rack::Attack activé - Protection anti-spam en place"