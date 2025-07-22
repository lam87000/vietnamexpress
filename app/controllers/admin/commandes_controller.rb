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
      # Gérer les notifications par email
      case params[:status]
      when 'confirmee'
        CommandeMailer.confirmation(@commande).deliver_now
      when 'refusee'
        CommandeMailer.rejection(@commande).deliver_now
      end
      
      # Rediriger vers la bonne page avec un message adapté
      case params[:status]
      when 'confirmee'
        redirect_to admin_commandes_path(status: 'confirmee'), notice: "Commande ##{@commande.id} confirmée."
      when 'refusee'
        redirect_to admin_commandes_path(status: 'en_attente'), notice: "Commande ##{@commande.id} refusée et client notifié."
      when 'prete'
        redirect_to admin_commandes_path(status: 'prete'), notice: "Commande ##{@commande.id} marquée comme prête."
      when 'recuperee'
        redirect_to admin_commandes_path(status: 'recuperee'), notice: "Commande ##{@commande.id} marquée comme récupérée."
      else
        redirect_to admin_commandes_path, notice: "Statut de la commande ##{@commande.id} mis à jour."
      end
    else
      redirect_to admin_commandes_path, alert: "Erreur lors de la mise à jour du statut."
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