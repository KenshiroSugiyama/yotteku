class RestaurantController < ApplicationController
  def index
    @res = Restaurant.all
  end

  def show
    @res = Restaurant.find(params[:id])
    @res_info = RestaurantInformation.find_by(Restaurant_id: @res.id)
  end
end
