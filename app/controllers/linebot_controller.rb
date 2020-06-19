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
          e = event.message['text']
          num = [*1..100]
          #user作成
          uid = event['source']['userId']
          user = User.find_by(uid: uid)
          unless user
            User.create(uid: uid)
          end
          req = Request.find_by(user_id: user.id)
          unless req
            Request.create(user_id: user.id)
          end

          if e.eql?('予約する')
            client.reply_message(event['replyToken'], template)
            #request作成
          elsif e.include?('肉系') || e.include?('魚介系') || e.include?('イタリアン')
            category = Category.find_by(name: e)
            req.update(category_id: category.id)
            client.reply_message(event['replyToken'], template2)
          elsif e.include?('~2000円') || e.include?('2000~3000円') || e.include?('3000~4000円') || e.include?('5000円~') 
            req.update(budget: e)
            message = {
              "type": "text",
              "text": "人数を数字のみ入力してください（例： 3 ）"
            }
            client.reply_message(event['replyToken'], message)
          elsif num.any?(e.to_i)
            req = Request.find_by(user_id: user.id)
            req.update(number_of_people: e.to_i)
            message = {
              type: 'text',
              text: e+'人ですね！ 何かご要望はありますか？（例： 掘りごたつ、個室）、ない場合は「なし」と入力'
            }
            client.reply_message(event['replyToken'], message)
          elsif e.include?('なし')
            message = {
              type: 'text',
              text: 'ありがとうございます'
            }
            client.reply_message(event['replyToken'], message)
          else
            message = {
              "type": "text",
              "text": e
            }
            client.reply_message(event['replyToken'], message)
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
            "text": "description",
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
            "text": "description",
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
            "text": "description",
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

  def template2
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "予算",
          "text": "希望予算を選択してください",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg"
          },
          "actions": [
              {
                "type": "postback",
                "label": "~2000円",
                "data": "0 2000",
                "text": "~2000円"
              },
              {
                "type": "postback",
                "label": "2000~3000円",
                "data": "2000 3000",
                "text": "2000~3000円"
              },
              {
                "type": "postback",
                "label": "3000~4000円",
                "data": "3000 4000",
                "text": "3000~4000円"
              },
              {
                "type": "postback",
                "label": "5000円~",
                "data": "5000 ",
                "text": "5000円~"
              }  
          ]
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
