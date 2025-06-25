class PlatsController < ApplicationController
  def index
    @categories = Category.includes(:plats).joins(:plats).where('plats.stock_quantity > 0').distinct.order(:id)
    @plats = Plat.available.includes(:category)
  end
  
  def show
    @plat = Plat.find(params[:id])
  end
end 