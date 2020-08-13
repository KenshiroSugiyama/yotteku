class ReservesController < ApplicationController
  def index
    scout_ids = Request.where(res_id: params[:id]).pluck(:scout_id)
    @scout = Scout.find(scout_ids)
    req = Request.find(@scout.request_id)
    @user = User.find(req.user_id)
  end
  
  def show
    @scout = Scout.find(params[:id])
    req = Request.find(@scout.request_id)
    @user = User.find(req.user_id)
  end
  
end
