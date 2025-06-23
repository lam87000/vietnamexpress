class Commande < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :plats, through: :order_items
  
  validates :jour_commande, presence: true
  validates :heure_retrait, presence: true
  validates :montant_total, presence: true, numericality: { greater_than: 0 }
  validates :client_nom, presence: true
  validates :client_telephone, presence: true
  validates :client_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :statut, inclusion: { in: %w[en_attente confirmee prete recuperee annulee] }
  
  before_validation :set_default_status
  before_validation :set_order_date
  
  scope :today, -> { where(jour_commande: Date.current) }
  scope :by_status, ->(status) { where(statut: status) }
  
  def total_items
    order_items.sum(:quantite)
  end
  
  def can_be_cancelled?
    %w[en_attente confirmee].include?(statut)
  end
  
  def formatted_pickup_time
    "#{jour_commande.strftime('%d/%m/%Y')} à #{heure_retrait.strftime('%H:%M')}"
  end
  
  private
  
  def set_default_status
    self.statut ||= 'en_attente'
  end
  
  def set_order_date
    self.jour_commande ||= Date.current
  end
end 