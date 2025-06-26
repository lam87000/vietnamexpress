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
  
  def image_path
    return nil if image_url.blank?
    
    # Si l'URL commence par http/https, c'est une URL externe (Cloudinary ou autre)
    if image_url.match?(/^https?:\/\//)
      image_url
    else
      # Pour les images locales, retourner le chemin depuis public/images/
      "/images/#{image_url}"
    end
  end
  
  def has_image?
    image_url.present?
  end
  
  def is_local_image?
    image_url.present? && !image_url.match?(/^https?:\/\//)
  end
  
  def is_cloudinary_image?
    image_url.present? && image_url.include?('cloudinary.com')
  end
  
  private
  
  def asset_path(filename)
    # Utiliser ActionView pour les assets
    ActionController::Base.helpers.asset_path(filename)
  rescue
    # Fallback si les helpers ne sont pas disponibles
    "/assets/#{filename}"
  end
end 