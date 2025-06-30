class Commande < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :plats, through: :order_items
  
  validates :jour_commande, presence: true
  validates :heure_retrait, presence: true
  validates :montant_total, numericality: { greater_than: 0 }, allow_nil: true
  validates :client_nom, presence: true
  validates :client_telephone, presence: true
  validates :client_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :email_not_disposable
  validate :email_domain_valid
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
  
  # SÉCURITÉ: Validation email renforcée
  def email_not_disposable
    return unless client_email.present?
    
    # Liste des domaines d'emails jetables les plus courants
    disposable_domains = [
      '10minutemail.com', '10minutemail.net', 'guerrillamail.com', 'mailinator.com',
      'tempmail.org', 'temp-mail.org', 'yopmail.com', 'jetable.org',
      'mailnator.com', 'maildrop.cc', 'throwaway.email', 'fakeinbox.com',
      'tempail.com', 'sharklasers.com', 'grr.la', 'getairmail.com'
    ]
    
    domain = client_email.split('@').last&.downcase
    
    if disposable_domains.include?(domain)
      errors.add(:client_email, "Les emails temporaires ne sont pas autorisés")
    end
  end
  
  def email_domain_valid
    return unless client_email.present?
    
    domain = client_email.split('@').last&.downcase
    
    # Vérification stricte du format du domaine
    # Format: au moins 2 caractères + point + extension 2+ caractères
    unless domain&.match?(/\A[a-z0-9\-]{2,}\.[a-z]{2,}\z/)
      errors.add(:client_email, "Domaine email invalide")
      return
    end
    
    # LISTE BLANCHE des domaines email légitimes SEULEMENT
    legitimate_domains = [
      # Grands fournisseurs internationaux
      'gmail.com', 'yahoo.com', 'yahoo.fr', 'hotmail.com', 'hotmail.fr',
      'outlook.com', 'outlook.fr', 'live.com', 'live.fr', 'msn.com',
      
      # Apple (moderne)
      'icloud.com',
      
      # Fournisseurs français
      'laposte.net', 'orange.fr', 'wanadoo.fr', 'free.fr', 
      'sfr.fr', 'bouyguestelecom.fr', 'neuf.fr', 'club-internet.fr',
      'bbox.fr', 'numericable.fr', 'red-sfr.fr'
    ]
    
    unless legitimate_domains.include?(domain)
      errors.add(:client_email, "Domaine email non reconnu. Exemples valides : jean@gmail.com, marie@yahoo.fr, paul@orange.fr, sophie@laposte.net")
    end
    
    # Blocage explicite de domaines frauduleux courants
    fraudulent_domains = [
      'lapost.com', 'gmai.com', 'yahooo.com', 'outlok.com',
      'test.com', 'example.com', 'fake.com', 'invalid.com',
      'com.com', 'org.org', 'net.net', 'fr.fr'
    ]
    
    if fraudulent_domains.include?(domain)
      errors.add(:client_email, "Domaine email frauduleux détecté")
    end
  end
end 