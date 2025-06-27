class CommandesController < ApplicationController
  before_action :set_commande, only: [:show]
  
  
  def show
    @order_items = @commande.order_items.includes(:plat)
  end
  
  
  def new
    clean_expired_cart
    @commande = Commande.new
    @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct.order(:id)
    @cart_items = session[:cart] || {}
    @total = calculate_cart_total
  end
  
  def create
    @commande = Commande.new(commande_params)
    
    if session[:cart].present?
      result = OrderCreationService.new(@commande, session[:cart]).call
      
      if result.success?
        session[:cart] = nil
        session[:cart_timestamp] = nil
        redirect_to @commande, notice: 'Votre commande a été enregistrée avec succès!'
      else
        flash.now[:alert] = result.error
        @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct.order(:id)
        @cart_items = session[:cart]
        @total = calculate_cart_total
        render :new
      end
    else
      flash.now[:alert] = "Votre panier est vide. Ajoutez des plats avant de confirmer votre commande."
      @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct.order(:id)
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
      # Mettre à jour le timestamp du panier à chaque ajout
      session[:cart_timestamp] = Time.current.to_i
      
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
    # Mettre à jour le timestamp du panier lors des modifications
    session[:cart_timestamp] = Time.current.to_i
    
    redirect_to new_commande_path
  end
  
  private
  
  def set_commande
    @commande = Commande.find(params[:id])
  end
  
  def clean_expired_cart
    return unless session[:cart].present?
    
    # Vérifier s'il y a un timestamp
    cart_timestamp = session[:cart_timestamp]
    
    if cart_timestamp.nil?
      # Si pas de timestamp, on l'ajoute maintenant pour les paniers existants
      session[:cart_timestamp] = Time.current.to_i
      return
    end
    
    # Calculer l'âge du panier en minutes
    cart_age_minutes = (Time.current.to_i - cart_timestamp) / 60
    
    # Nettoyer le panier s'il a plus de 20 minutes d'inactivité
    if cart_age_minutes > 20
      session[:cart] = nil
      session[:cart_timestamp] = nil
      flash[:notice] = "Votre panier a été vidé automatiquement après 20 minutes d'inactivité."
    end
  end
  
  def commande_params
    params.require(:commande).permit(
      :heure_retrait, :client_nom, :client_telephone, 
      :client_email, :notes
    )
  end
  
end 