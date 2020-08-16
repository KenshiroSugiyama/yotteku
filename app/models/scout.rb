class Scout < ApplicationRecord
    belongs_to :restaurant
    belongs_to :request, dependent: :destroy
end
