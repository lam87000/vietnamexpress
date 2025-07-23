class OrderCreationService
  def initialize(commande, cart_items)
    @commande = commande
    @cart_items = cart_items
    @errors = []
  end
  
  def call
    # Vérifier si les commandes sont acceptées avant tout traitement
    unless restaurant_accepting_orders?
      return OpenStruct.new(success?: false, error: "Les commandes sont actuellement suspendues")
    end
    
    ActiveRecord::Base.transaction do
      calculate_total
      create_order
      
      # SÉCURITÉ: Arrêter immédiatement si la commande est invalide
      if @errors.any?
        raise ActiveRecord::Rollback
      end
      
      create_order_items
      update_stock
      
      if @errors.any?
        raise ActiveRecord::Rollback
      end
    end
    
    if @errors.any?
      OpenStruct.new(success?: false, error: @errors.join(', '))
    else
      OpenStruct.new(success?: true, commande: @commande)
    end
  end
  
  private
  
  def restaurant_accepting_orders?
    # Réutilise la même logique que ApplicationController
    timestamp = Rails.cache.read('orders_disabled_until')
    timestamp.nil? || timestamp < Time.current
  end
  
  def calculate_total
    @total = 0
    @cart_items.each do |plat_id, quantity|
      plat = Plat.find(plat_id)
      @total += plat.prix * quantity
    end
    @commande.montant_total = @total
  end
  
  def create_order
    unless @commande.save
      @errors += @commande.errors.full_messages
    end
  end
  
  def create_order_items
    @cart_items.each do |plat_id, quantity|
      plat = Plat.lock.find(plat_id) # Lock pessimiste pour éviter race conditions
      quantity = quantity.to_i
      
      # SÉCURITÉ: Validation stricte des quantités
      if quantity <= 0 || quantity > 10
        @errors << "Quantité invalide pour #{plat.nom}: #{quantity} (1-10 autorisée)"
        next
      end
      
      # SÉCURITÉ: Vérification du prix (recalculé depuis la DB)
      prix_reel = plat.prix
      
      # Vérifier le stock de manière atomique
      if plat.stock_quantity < quantity
        @errors << "Stock insuffisant pour #{plat.nom} (demandé: #{quantity}, disponible: #{plat.stock_quantity})"
        next
      end
      
      order_item = @commande.order_items.build(
        plat: plat,
        quantite: quantity,
        prix_unitaire: prix_reel # Prix de la DB, jamais du client
      )
      
      unless order_item.save
        @errors += order_item.errors.full_messages
      end
    end
  end
  
  def update_stock
    @cart_items.each do |plat_id, quantity|
      plat = Plat.lock.find(plat_id) # Lock pessimiste pour atomicité
      quantity = quantity.to_i
      
      # Double vérification du stock avant décrément
      if plat.stock_quantity < quantity
        @errors << "Stock modifié pendant la commande pour #{plat.nom}"
        next
      end
      
      # Décrément atomique du stock
      plat.update!(stock_quantity: plat.stock_quantity - quantity)
      
      Rails.logger.info "📦 Stock mis à jour: #{plat.nom} (#{quantity} vendus, reste: #{plat.stock_quantity})"
    end
  end
end 