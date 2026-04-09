class PageController < ApplicationController
  def home
    @categories = Category.includes(:plats).joins(:plats).where(plats: { available: true }).distinct.order(:id)
  end

  def contact
    # Méthode pour la page de contact
  end
end 