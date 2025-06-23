class Plat < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many :commandes, through: :order_items
  
  validates :nom, presence: true
  validates :prix, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :available, -> { where('stock_quantity > 0') }
  scope :by_category, ->(category) { where(category: category) }
  
  def available?
    stock_quantity > 0
  end
  
  def formatted_price
    "#{prix.to_f}€"
  end
end 