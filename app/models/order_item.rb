class OrderItem < ApplicationRecord
  belongs_to :commande
  belongs_to :plat
  
  validates :quantite, presence: true, numericality: { greater_than: 0 }
  validates :prix_unitaire, presence: true, numericality: { greater_than: 0 }
  
  before_validation :set_unit_price
  
  def total_price
    quantite * prix_unitaire
  end
  
  private
  
  def set_unit_price
    self.prix_unitaire = plat.prix if plat
  end
end 