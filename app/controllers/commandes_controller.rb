class CommandesController < ApplicationController
  before_action :set_commande, only: [:show]
  before_action :check_orders_enabled, only: [:create, :add_to_cart, :update_cart]
  
  
  def show
    @order_items = @commande.order_items.includes(:plat)
  end
  
  
  def new
     # On ajoute cette ligne pour passer le statut à la vue : permet de griser le bouton sur la page commande si les commandes sont fermées
    @orders_enabled = restaurant_accepting_orders?
    clean_expired_cart
    @commande = Commande.new
    @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct.order(:id)
    @cart_items = secure_cart
    @total = calculate_cart_total
  end
  
  def create
    @commande = Commande.new(commande_params)
    
    cart_items = secure_cart
    if cart_items.present?
      result = OrderCreationService.new(@commande, cart_items).call
      
      if result.success?
        # Vider le panier sécurisé
        self.secure_cart = {}
        session[:cart_timestamp] = nil
        redirect_to @commande, notice: 'Votre commande a été enregistrée avec succès!'
      else
        flash.now[:alert] = result.error
        @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct.order(:id)
        @cart_items = cart_items
        @total = calculate_cart_total
        render :new
      end
    else
      flash.now[:alert] = "Votre panier est vide. Ajoutez des plats avant de confirmer votre commande."
      @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct.order(:id)
      @cart_items = {}
      @total = calculate_cart_total
      render :new
    end
  end
  
  # Actions pour gérer le panier
  def add_to_cart
    plat = Plat.find(params[:plat_id])
    quantity = params[:quantity].to_i
    
    # SÉCURITÉ: Validation stricte des quantités
    if quantity <= 0 || quantity > 10
      respond_to do |format|
        format.html { 
          redirect_to new_commande_path, alert: "Quantité invalide (1-10 autorisée)" 
        }
        format.json { 
          render json: { 
            success: false, 
            message: "Quantité invalide (1-10 autorisée)"
          }
        }
      end
      return
    end
    
    if plat.available? && quantity > 0
      # Utiliser le panier sécurisé
      cart = secure_cart
      cart[plat.id.to_s] = (cart[plat.id.to_s] || 0) + quantity
      self.secure_cart = cart
      
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
            cart_count: cart.values.sum,
            cart_total: calculate_cart_total.to_f,
            cart_html: render_to_string(
              partial: 'cart_items',
              formats: [:html],
              locals: { 
                cart_items: cart, 
                total: calculate_cart_total,
                commande: @commande || Commande.new
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
    cart = secure_cart
    plat_id = params[:plat_id].to_s
    cart.delete(plat_id)
    self.secure_cart = cart
    
    respond_to do |format|
      format.html { 
        redirect_to new_commande_path, notice: "Plat retiré du panier" 
      }
      
      format.json { 
        render json: {
          success: true,
          message: "Plat retiré du panier",
          cart_count: cart.values.sum,
          cart_total: calculate_cart_total.to_f,
          cart_html: render_to_string(
            partial: 'cart_items',
            formats: [:html],
            locals: { 
              cart_items: cart, 
              total: calculate_cart_total,
              commande: @commande || Commande.new
            }
          )
        }
      }
    end
  end
  
  def update_cart
    cart = secure_cart
    cart[params[:plat_id].to_s] = params[:quantity].to_i
    cart.reject! { |k, v| v <= 0 }
    self.secure_cart = cart
    # Mettre à jour le timestamp du panier lors des modifications
    session[:cart_timestamp] = Time.current.to_i
    
    redirect_to new_commande_path
  end
  
  def clear_cart
    self.secure_cart = {}
    session[:cart_timestamp] = nil
    
    respond_to do |format|
      format.html { 
        redirect_to new_commande_path, notice: "Votre panier a été vidé" 
      }
      format.json { 
        render json: {
          success: true,
          message: "Votre panier a été vidé",
          cart_count: 0,
          cart_total: 0.0,
          cart_html: render_to_string(
            partial: 'cart_items',
            formats: [:html],
            locals: { 
              cart_items: {}, 
              total: 0,
              commande: @commande || Commande.new
            }
          )
        }
      }
    end
  end
  
  private
  
  def set_commande
    @commande = Commande.find(params[:id])
  end
  
  def clean_expired_cart
    cart = secure_cart
    return unless cart.present?
    
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
      self.secure_cart = {}
      session[:cart_timestamp] = nil
      flash[:notice] = "Votre panier a été vidé automatiquement après 20 minutes d'inactivité."
    end
  end
  
  def check_orders_enabled
    unless restaurant_accepting_orders?
      respond_to do |format|
        format.html { 
          redirect_to new_commande_path, alert: "Les commandes sont actuellement suspendues." 
        }
        format.json { 
          render json: { success: false, message: "Les commandes sont actuellement suspendues." }
        }
      end
    end
  end

  def commande_params
    params.require(:commande).permit(
      :heure_retrait, :client_nom, :client_telephone, 
      :client_email, :notes
    )
  end
  
end 