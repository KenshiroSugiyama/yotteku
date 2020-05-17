module Api
  module V1
    class BookssController < Api::V1::ApplicationController
      def index
        render json: current_user.books, status: 200
      end
    end
  end
end
