class User < ApplicationRecord
    has_many :requests

    has_many :users_restaurants
end
