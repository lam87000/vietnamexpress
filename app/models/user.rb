class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :admin, inclusion: { in: [true, false] }
  
  scope :admins, -> { where(admin: true) }
  
  def admin?
    admin == true
  end
end
