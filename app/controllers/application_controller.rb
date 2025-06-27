class ApplicationController < ActionController::Base
  # Helper method pour calculer le total du panier
  def calculate_cart_total
    return 0 unless session[:cart]
    
    total = 0
    session[:cart].each do |plat_id, quantity|
      plat = Plat.find(plat_id)
      total += plat.prix * quantity
    end
    total
  end
  helper_method :calculate_cart_total
end
