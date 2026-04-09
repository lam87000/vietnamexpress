class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:edit, :update, :destroy]
  
  def index
    @categories = Category.includes(:plats).order(:name)
  end
  
  def new
    @category = Category.new
  end
  
  def edit
  end
  
  def create
    @category = Category.new(category_params)
    
    if @category.save
      redirect_to admin_categories_path, notice: 'Catégorie créée avec succès'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: 'Catégorie mise à jour avec succès'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @category.plats.any?
      redirect_to admin_categories_path, alert: 'Impossible de supprimer une catégorie contenant des plats'
    else
      @category.destroy
      redirect_to admin_categories_path, notice: 'Catégorie supprimée avec succès'
    end
  end
  
  private
  
  def set_category
    @category = Category.find(params[:id])
  end
  
  def category_params
    params.require(:category).permit(:name, :description)
  end
end