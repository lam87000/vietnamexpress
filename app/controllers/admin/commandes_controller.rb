class Admin::CommandesController < Admin::BaseController
  before_action :set_commande, only: [:show, :edit, :update, :change_status]
  
  def index
    @commandes = Commande.includes(:order_items, :plats)
                        .order(created_at: :desc)
    
    # Filtres
    @commandes = @commandes.by_status(params[:status]) if params[:status].present?
    @commandes = @commandes.today if params[:today] == 'true'
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
      
      redirect_to admin_commandes_path, notice: "Commande marquée comme #{params[:status]}"
    else
      redirect_to admin_commandes_path, alert: 'Erreur lors de la mise à jour'
    end
  end
  
  private
  
  def set_commande
    @commande = Commande.find(params[:id])
  end
  
  def commande_params
    params.require(:commande).permit(:statut, :notes)
  end
end