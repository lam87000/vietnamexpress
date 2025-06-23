class Category < ApplicationRecord
  has_many :plats, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
end 