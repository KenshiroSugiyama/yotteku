class RequestControllerController < LinebotController
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
      public_method(:resreq).super_method.call

      #redirect_to "https://line.me/R/"
    end
  end

  def show
    @req = Request.find(params[:id])
  end
end
