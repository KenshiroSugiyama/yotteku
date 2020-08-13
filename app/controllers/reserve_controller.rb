class ReserveController < ApplicationController
  def index
    scout_ids = Request.where(res_id: params[:id]).pluck(:scout_id)
    @scout = Scout.find(scout_ids)
  end
  
  def show
    @scout = Scout.find(params[:id])
    @res = Restaurant.find(@scout.restaurant_id)
    req = Request.find(@scout.request_id)
    @user = User.find(req.user_id)
  end
  
end
