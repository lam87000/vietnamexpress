class ApplicationController < ActionController::Base
  # SÉCURITÉ: Chiffrement des données sensibles du panier
  private
  
  def cart_encryptor
    @cart_encryptor ||= ActiveSupport::MessageEncryptor.new(
      Rails.application.secret_key_base[0..31]
    )
  end
  
  def encrypt_cart_data(cart_data)
    return nil if cart_data.blank?
    cart_encryptor.encrypt_and_sign(cart_data.to_json)
  end
  
  def decrypt_cart_data(encrypted_data)
    return {} if encrypted_data.blank?
    
    data = cart_encryptor.decrypt_and_verify(encrypted_data)
    JSON.parse(data)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage, JSON::ParserError
    Rails.logger.warn "🚨 Session panier corrompue ou manipulée"
    {} # Session corrompue = panier vide
  end
  
  def secure_cart
    decrypt_cart_data(session[:encrypted_cart])
  end
  
  def secure_cart=(cart_data)
    session[:encrypted_cart] = encrypt_cart_data(cart_data)
  end
  
  public
  
  # Helper method pour calculer le total du panier (version sécurisée)
  def calculate_cart_total
    cart = secure_cart
    return 0 if cart.blank?
    
    total = 0
    cart.each do |plat_id, quantity|
      plat = Plat.find(plat_id)
      total += plat.prix * quantity
    end
    total
  rescue ActiveRecord::RecordNotFound
    # Plat supprimé = nettoyage du panier
    self.secure_cart = {}
    0
  end
  
  def cart_count
    secure_cart.values.sum
  end
  
  # CETTE LIGNE DOIT ÊTRE ICI, DANS LE CONTRÔLEUR
  helper_method :calculate_cart_total, :secure_cart, :cart_count
end