class Admin::CommandesController < Admin::BaseController
  before_action :set_commande, only: [:show, :edit, :update, :change_status, :delete_completed]
  
  def index
    @commandes = Commande.includes(:order_items, :plats)
    
    # Filtres
    @commandes = @commandes.by_status(params[:status]) if params[:status].present?
    @commandes = @commandes.today if params[:today] == 'true'
    
    # Tri par heure de retrait (plus urgent en premier) pour toutes sauf "Toutes"
    if params[:status].present?
      @commandes = @commandes.sort_by { |c| Time.parse(c.heure_retrait.to_s) }
    else
      @commandes = @commandes.order(created_at: :desc)
    end
    
    # Compter toutes les commandes en attente pour le badge
    @pending_count = Commande.today.where(statut: 'en_attente').count
  end
  
  def show
    @order_items = @commande.order_items.includes(:plat)
  end
  
  def edit
  end
  
  def update
    if @commande.update(commande_params)
      redirect_to admin_commande_path(@commande), notice: 'Commande mise à jour'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def change_status
    if @commande.update(statut: params[:status])
      # Envoyer un email de confirmation si la commande est confirmée
      if params[:status] == 'confirmee'
        CommandeMailer.confirmation(@commande).deliver_later
      end
      
      # Rediriger vers les commandes confirmées après validation
      if params[:status] == 'confirmee'
        redirect_to admin_commandes_path(status: 'confirmee'), notice: "Commande ##{@commande.id} confirmée"
      elsif params[:status] == 'prete'
        redirect_to admin_commandes_path(status: 'prete'), notice: "Commande ##{@commande.id} prête"
      elsif params[:status] == 'recuperee'
        redirect_to admin_commandes_path(status: 'recuperee'), notice: "Commande ##{@commande.id} récupérée"
      else
        redirect_to admin_commandes_path, notice: "Commande marquée comme #{params[:status]}"
      end
    else
      redirect_to admin_commandes_path, alert: 'Erreur lors de la mise à jour'
    end
  end
  
  def delete_completed
    commande_id = @commande.id
    client_nom = @commande.client_nom
    
    # Supprimer les order_items associés puis la commande
    @commande.order_items.destroy_all
    @commande.destroy
    
    redirect_to admin_commandes_path(status: 'confirmee'), notice: "Commande ##{commande_id} de #{client_nom} supprimée définitivement"
  end
  
  private
  
  def set_commande
    @commande = Commande.find(params[:id])
  end
  
  def commande_params
    params.require(:commande).permit(:statut, :notes)
  end
end