class RequestControllerController < LinebotController
  require "net/http"
  require "json"
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
      # flash[:success] = '更新されました'

      uri = URI.parse("https://api.line.me/v2/bot/message/push")
      headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + ENV['LINE_CHANNEL_TOKEN'],
      }
      
      post = {
        'to': 'Uc839d0d386e217ea31ba4482a3cd2d26',
        'messages': [
            {
                'type': 'text',
                'text': '要望入力完了！'
            }
        ]
      }
      
      req = Net::HTTP.new(uri.host, uri.port)
      req.use_ssl = uri.scheme === "https"
      req.post(uri.path, post.to_json,headers)
    
      redirect_to "https://line.me/R/"
    end
  end

  def show
    @req = Request.find(params[:id])
  end
end


