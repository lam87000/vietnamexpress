class CategoriesController < ApplicationController
  def index
    @categories = Category.includes(:plats).order(:display_order, :name)
  end
  
  def show
    @category = Category.find(params[:id])
    @plats = @category.plats.available
  end
end 