class Restaurant < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
    #belongs_to :category
    has_one :restaurant_information
    has_many :scouts
    has_many :users_restaurants
    has_many :scout_templates

   #validation
   validates :name, presence: true,on: :update
   validates :phone_number, presence: true,on: :update
   validates :category_id, presence: true,on: :update
   validates :uid, presence: true
end
