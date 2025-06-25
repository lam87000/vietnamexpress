class PlatsController < ApplicationController
  def index
    @categories = Category.all.order(:id)
    @plats = Plat.available.includes(:category)
  end
  
  def show
    @plat = Plat.find(params[:id])
  end
end 