class Category < ApplicationRecord
    has_many :restaurants
    has_many :requests,foreign_key: true
end
