class Admin::PlatsController < Admin::BaseController
  before_action :set_plat, only: [:show, :edit, :update, :destroy]
  
  def index
    @categories = Category.includes(:plats).order(:id)
    @plats = Plat.includes(:category)
    @low_stock_plats = Plat.where('stock_quantity <= 5')
  end
  
  def show
  end
  
  def new
    @plat = Plat.new
    @categories = Category.all
  end
  
  def edit
    @categories = Category.all
  end
  
  def create
    @plat = Plat.new(plat_params)
    
    if @plat.save
      redirect_to admin_plats_path, notice: 'Plat créé avec succès'
    else
      @categories = Category.all
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @plat.update(plat_params)
      redirect_to admin_plats_path, notice: 'Plat mis à jour avec succès'
    else
      @categories = Category.all
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @plat.order_items.any?
      redirect_to admin_plats_path, alert: 'Impossible de supprimer un plat déjà commandé'
    else
      @plat.destroy
      redirect_to admin_plats_path, notice: 'Plat supprimé avec succès'
    end
  end
  
  private
  
  def set_plat
    @plat = Plat.find(params[:id])
  end
  
  def plat_params
    params.require(:plat).permit(:nom, :description, :prix, :stock_quantity, :category_id, :image_url)
  end
end