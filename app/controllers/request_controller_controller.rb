class RequestControllerController < LinebotController
  require "net/http"
  require "json"
  
  def edit
    @req = Request.find(params[:id])
    @category = Category.find(@req.category_id)
  end

  def update
    @req = Request.find(params[:id])
    @category = Category.find(@req.category_id)
    #@req.hope = params[:hope]
    if @req.update(hope: params[:hope])
      # flash[:success] = '更新されました'

      uri = URI.parse("https://api.line.me/v2/bot/message/push")
      headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + ENV['LINE_CHANNEL_TOKEN'],
      }
      user = @req.user_id
      userId = User.find(user).uid
      puts userId
      post = {
        'to': userId,
        'messages': [
          {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "リクエストが完成しました\r\nジャンル： #{@category.name} \r\nお酒： #{@req.freedrink}\r\n予算： #{@req.budget}\r\n人数： #{@req.number_of_people.to_s}\r\n開始時間： #{@req.time}\r\n要望:  #{@req.hope}\b\n店側にリクエストを送ってもいいですか？",
                "actions": [
                    {
                      "type": "message",
                      "label": "OK!",
                      "text": "OK!"
                    },
                    {
                      "type": "message",
                      "label": "キャンセル",
                      "text": "リクエストキャンセル"
                    }
                ]
            }
          }
        ]
      }
      puts userId
      req = Net::HTTP.new(uri.host, uri.port)
      req.use_ssl = uri.scheme === "https"
      req.post(uri.path, post.to_json,headers)
    
      redirect_to "https://line.me/R/"
    end
  end

  def show
    @req = Request.find(params[:id])
  end

  
  def confirm_send_request
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "リクエストが完成しました\r\nジャンル： #{@category.name} \r\nお酒： #{@req.freedrink}\r\n予算： #{@req.budget}\r\n人数： #{@req.number_of_people.to_s}\r\n開始時間： #{@req.time}\r\n要望:  #{@req.hope}\b\n店側にリクエストを送ってもいいですか？",
          "actions": [
              {
                "type": "message",
                "label": "OK!",
                "text": "OK!"
              },
              {
                "type": "message",
                "label": "キャンセル",
                "text": "リクエストキャンセル"
              }
          ]
      }
    }
  end
end


