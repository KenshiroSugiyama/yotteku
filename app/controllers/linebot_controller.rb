class LinebotController < ApplicationController
    require 'line/bot'

    protect_from_forgery :except => [:callback]
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'].eql?('予約する')
            client.reply_message(event['replyToken'], template)
          end
        end
      end
    end
    head :ok
  end

private

def template
    {
      "type": "template",
      "altText": "？",
      "template": {
          "type": "carousel",
          "text": "何食べたい？",
          "columns": [
          {
            "thumbnailImageUrl": "https://rimage.gnst.jp/rest/img/6sp1wtu60000/s_0n6m.jpg?t=1585036850",
            "imageBackgroundColor": "#FFFFFF",
            "title": "肉系",
            "defaultAction": {
                "type": "postback",
                "label": "選択",
                "data": "category=meat",
                "text": "肉系"
            },
            "actions": [
                {
                    "type": "postback",
                    "label": "選択",
                    "data": "category=meat",
                    "text": "肉系"
                },
            ]
          },
          {
            "thumbnailImageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTdJUj8MRgLDP64ptvYCflvOwcOKBrjnvtWd3MX86QD1gNl8-el&usqp=CAU",
            "imageBackgroundColor": "#000000",
            "title": "魚介系",
            "defaultAction": {
                "type": "postback",
                "label": "選択",
                "data": "category=fish",
                "text": "魚介系"
            },
            "actions": [
                {
                    "type": "postback",
                    "label": "選択",
                    "data": "category=fish",
                    "text": "魚介系"
                },
            ]
          },
          {
            "thumbnailImageUrl": "https://tblg.k-img.com/resize/660x370c/restaurant/images/Rvw/131355/131355648.jpg?token=0890a11&api=v2",
            "imageBackgroundColor": "#000000",
            "title": "イタリアン",
            "defaultAction": {
                "type": "postback",
                "label": "選択",
                "data": "category=italy",
                "text": "イタリアン"
            },
            "actions": [
                {
                    "type": "postback",
                    "label": "選択",
                    "data": "category=italy",
                    "text": "イタリアン"
                },
            ]
          }
      ],
      "imageAspectRatio": "rectangle",
      "imageSize": "cover"
  }
    }
  end

# LINE Developers登録完了後に作成される環境変数の認証
  def client
    @client ||= Line::Bot::Client.new { |config|
     # config.channel_id = ENV["1654324140"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
