class PlatsController < ApplicationController
  def index
    @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct
    @plats = Plat.available.includes(:category)
  end
  
  def show
    @plat = Plat.find(params[:id])
  end
end 