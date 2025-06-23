class CommandesController < ApplicationController
  before_action :set_commande, only: [:show, :edit, :update, :destroy]
  
  def index
    @commandes = Commande.includes(:order_items, :plats)
                        .order(created_at: :desc)
  end
  
  def show
    @order_items = @commande.order_items.includes(:plat)
  end
  
  def edit
    # Seules les commandes en attente ou confirmées peuvent être modifiées
    unless @commande.can_be_cancelled?
      redirect_to @commande, alert: "Cette commande ne peut plus être modifiée."
      return
    end
  end
  
  def update
    unless @commande.can_be_cancelled?
      redirect_to @commande, alert: "Cette commande ne peut plus être modifiée."
      return
    end
    
    if @commande.update(commande_edit_params)
      redirect_to @commande, notice: 'Commande mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    # Seules les commandes en attente ou confirmées peuvent être annulées
    unless @commande.can_be_cancelled?
      redirect_to @commande, alert: "Cette commande ne peut plus être annulée."
      return
    end
    
    # Remettre le stock en place avant de supprimer
    @commande.order_items.each do |item|
      plat = item.plat
      plat.update!(stock_quantity: plat.stock_quantity + item.quantite)
    end
    
    # Marquer comme annulée plutôt que supprimer (pour l'historique)
    @commande.update!(statut: 'annulee')
    
    redirect_to commandes_path, notice: 'Commande annulée avec succès. Le stock a été remis à jour.'
  end
  
  def new
    @commande = Commande.new
    @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct
    @cart_items = session[:cart] || {}
    @total = calculate_cart_total
  end
  
  def create
    @commande = Commande.new(commande_params)
    
    if session[:cart].present?
      result = OrderCreationService.new(@commande, session[:cart]).call
      
      if result.success?
        session[:cart] = nil
        redirect_to @commande, notice: 'Votre commande a été enregistrée avec succès!'
      else
        flash.now[:alert] = result.error
        @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct
        @cart_items = session[:cart]
        @total = calculate_cart_total
        render :new
      end
    else
      flash.now[:alert] = "Votre panier est vide. Ajoutez des plats avant de confirmer votre commande."
      @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct
      @cart_items = session[:cart] || {}
      @total = calculate_cart_total
      render :new
    end
  end
  
  # Actions pour gérer le panier
  def add_to_cart
    plat = Plat.find(params[:plat_id])
    quantity = params[:quantity].to_i
    
    if plat.available? && quantity > 0
      session[:cart] ||= {}
      session[:cart][plat.id.to_s] = (session[:cart][plat.id.to_s] || 0) + quantity
      
      respond_to do |format|
        format.html { 
          redirect_to new_commande_path, notice: "#{plat.nom} ajouté au panier" 
        }
        
        format.json { 
          render json: {
            success: true,
            message: "#{plat.nom} ajouté au panier",
            cart_count: session[:cart].values.sum,
            cart_total: calculate_cart_total.to_f,
            cart_html: render_to_string(
              partial: 'cart_items_json',
              formats: [:html],
              locals: { 
                cart_items: session[:cart], 
                total: calculate_cart_total
              }
            )
          }
        }
      end
    else
      respond_to do |format|
        format.html { 
          redirect_to new_commande_path, alert: "Impossible d'ajouter ce plat" 
        }
        
        format.json { 
          render json: { 
            success: false, 
            message: "Impossible d'ajouter ce plat"
          }
        }
      end
    end
  end
  
  def remove_from_cart
    plat_id = params[:plat_id].to_s
    session[:cart]&.delete(plat_id)
    
    respond_to do |format|
      format.html { 
        redirect_to new_commande_path, notice: "Plat retiré du panier" 
      }
      
      format.json { 
        render json: {
          success: true,
          message: "Plat retiré du panier",
          cart_count: session[:cart]&.values&.sum || 0,
          cart_total: calculate_cart_total.to_f,
          cart_html: render_to_string(
            partial: 'cart_items_json',
            formats: [:html],
            locals: { 
              cart_items: session[:cart] || {}, 
              total: calculate_cart_total
            }
          )
        }
      }
    end
  end
  
  def update_cart
    session[:cart] ||= {}
    session[:cart][params[:plat_id].to_s] = params[:quantity].to_i
    session[:cart].reject! { |k, v| v <= 0 }
    
    redirect_to new_commande_path
  end
  
  private
  
  def set_commande
    @commande = Commande.find(params[:id])
  end
  
  def commande_params
    params.require(:commande).permit(
      :heure_retrait, :client_nom, :client_telephone, 
      :client_email, :notes
    )
  end
  
  def commande_edit_params
    # Pour l'édition, on limite aux champs "sûrs" à modifier
    params.require(:commande).permit(:heure_retrait, :notes)
  end
  
  def calculate_cart_total
    return 0 unless session[:cart]
    
    total = 0
    session[:cart].each do |plat_id, quantity|
      plat = Plat.find(plat_id)
      total += plat.prix * quantity
    end
    total
  end
end 