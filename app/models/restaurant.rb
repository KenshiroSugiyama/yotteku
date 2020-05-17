class Restaurant < ApplicationRecord
    belongs_to :category
    has_one :restaurant_information

    has_many :users_restaurants
end
