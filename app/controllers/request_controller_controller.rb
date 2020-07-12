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
      flash[:success] = '更新されました'

      uri = URI.parse("https://api.line.me/v2/bot/message/push")
      HEADERS = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + ENV['LINE_CHANNEL_TOKEN'],
      }
      
      POST = {
        'to': 'Uc839d0d386e217ea31ba4482a3cd2d26',
        'messages': [
            {
                'type': 'text',
                'text': 'カレーぱんが焼けました！'
            }
        ]
      }
      
      req = Net::HTTP.new(uri.host, uri.port)
      req.use_ssl = uri.scheme === "https"
      req.post(uri.path, POST.to_json,HEADERS)
    
    
      
     
    # POSTデータを設定
    
    # 実行
    REQ = requests.post(CH, headers=HEADERS, data=json.dumps(POST))
     
      # LinebotController.resreq
      #redirect_to "https://line.me/R/"
    end
  end

  def show
    @req = Request.find(params[:id])
  end
end


