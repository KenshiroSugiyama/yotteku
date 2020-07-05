class RequestControllerController < ApplicationController
  def new
    
  end

  def create
    
  end

  def edit
    @req = Request.find(params[:id])
  end

  def update
    @req = Request.find(params[:id])
    #@req.hope = params[:hope]
    if @req.update(hope: params[:hope])
      flash[:success] = '更新されました'

      redirect_to request_controller_show_path(id: @req.id)
    end
  end

  def show
    @req = Request.find(params[:id])
  end
end
