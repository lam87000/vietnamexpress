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
    # Gestion de l'upload Cloudinary avant de créer le plat
    plat_attributes = plat_params
    if params[:plat][:photo_upload].present?
      begin
        result = Cloudinary::Uploader.upload(params[:plat][:photo_upload].tempfile.path,
          folder: "restaurant_plats",
          transformation: [
            { width: 500, height: 500, crop: "fill", quality: "auto", fetch_format: "auto" }
          ]
        )
        plat_attributes = plat_attributes.merge(image_url: result['secure_url'])
      rescue => e
        flash.now[:alert] = "Erreur lors de l'upload de l'image: #{e.message}"
        @categories = Category.all
        render :new, status: :unprocessable_entity
        return
      end
    end
    
    @plat = Plat.new(plat_attributes)
    
    if @plat.save
      redirect_to admin_plats_path, notice: 'Plat créé avec succès'
    else
      @categories = Category.all
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    # Gestion de l'upload Cloudinary
    if params[:plat][:photo_upload].present?
      begin
        result = Cloudinary::Uploader.upload(params[:plat][:photo_upload].tempfile.path,
          folder: "restaurant_plats",
          transformation: [
            { width: 500, height: 500, crop: "fill", quality: "auto", fetch_format: "auto" }
          ]
        )
        # Supprimer l'ancienne image de Cloudinary si elle existe
        if @plat.image_url.present? && @plat.image_url.include?('cloudinary.com')
          begin
            public_id = @plat.image_url.split('/').last.split('.').first
            Cloudinary::Uploader.destroy("restaurant_plats/#{public_id}")
          rescue => e
            # Log l'erreur mais continue le processus
            Rails.logger.warn "Impossible de supprimer l'ancienne image: #{e.message}"
          end
        end
        
        plat_params_with_image = plat_params.merge(image_url: result['secure_url'])
      rescue => e
        flash.now[:alert] = "Erreur lors de l'upload de l'image: #{e.message}"
        @categories = Category.all
        render :edit, status: :unprocessable_entity
        return
      end
    else
      plat_params_with_image = plat_params
    end
    
    if @plat.update(plat_params_with_image)
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