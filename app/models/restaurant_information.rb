class RestaurantInformation < ApplicationRecord
    belongs_to :restaurant
    validates :menu, presence: true
    validates :price_min, presence: true
    validates :price_max, presence: true
    validates :address, presence: true
    validates :url, presence: true
end
