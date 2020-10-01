class ReservesController < ApplicationController
  def index
    scout_ids = Request.where(res_id: params[:id]).pluck(:scout_id)
    @scout = Scout.find(scout_ids)
  end
  
  def show
    @scout = Scout.find(params[:id])
    @req = Request.find(@scout.request_id)
    @user = User.find(@req.user_id)
  end

  def admin
  end

  def admin_index
    @reqs = Request.where(status: true) 
  end

  def admin_show
    @req = Request.find(params[:id])
    @scout = Scout.find(@req.scout_id)
  end

  
  
end
