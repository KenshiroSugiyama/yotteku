class User < ApplicationRecord
    has_many :requests,foreign_key: true

    has_many :users_restaurants
end
