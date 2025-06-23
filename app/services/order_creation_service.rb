class OrderCreationService
  def initialize(commande, cart_items)
    @commande = commande
    @cart_items = cart_items
    @errors = []
  end
  
  def call
    ActiveRecord::Base.transaction do
      calculate_total
      create_order
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
      plat = Plat.find(plat_id)
      
      # Vérifier le stock
      if plat.stock_quantity < quantity
        @errors << "Stock insuffisant pour #{plat.nom}"
        next
      end
      
      order_item = @commande.order_items.build(
        plat: plat,
        quantite: quantity,
        prix_unitaire: plat.prix
      )
      
      unless order_item.save
        @errors += order_item.errors.full_messages
      end
    end
  end
  
  def update_stock
    @cart_items.each do |plat_id, quantity|
      plat = Plat.find(plat_id)
      plat.update!(stock_quantity: plat.stock_quantity - quantity)
    end
  end
end 