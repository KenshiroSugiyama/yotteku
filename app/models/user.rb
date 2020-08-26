class User < ApplicationRecord
    has_many :requests,foreign_key: true

    has_many :users_restaurants
    
    #validation
    validates :name, presence: true
    validates :email, presence: true
    validates :uid, presence: true
end


