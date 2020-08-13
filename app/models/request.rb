class Request < ApplicationRecord
    belongs_to :category
    belongs_to :user
    has_many :scouts
end
