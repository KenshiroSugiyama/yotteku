class Scout < ApplicationRecord
    belongs_to :restaurant
    belongs_to :request
end
