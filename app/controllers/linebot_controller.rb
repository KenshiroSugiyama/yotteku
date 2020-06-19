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
            user = User.find_by(uid: uid)
          end
          

          if e.eql?('予約する')
            client.reply_message(event['replyToken'], template)
          elsif e.include?('肉系') || e.include?('魚介系') || e.include?('イタリアン')
            category = Category.find_by(name: e)
            req = Request.find_by(user_id: user.id)
            unless req
              Request.create(user_id: user.id,category_id: category.id)
            end
            client.reply_message(event['replyToken'], template2)
          elsif e.include?('~2000円') || e.include?('2000~3000円') || e.include?('3000~4000円') || e.include?('5000円~') 
            req = Request.find_by(user_id: user.id)
            req.update(budget: e)
            message = {
              "type": "text",
              "text": "人数を数字のみ入力してください（例： 3 ）"
            }
            client.reply_message(event['replyToken'], message)
          elsif num.any?(e.to_i)
            req = Request.find_by(user_id: user.id)
            req.update(number_of_people: e.to_i)
            client.reply_message(event['replyToken'], template3)
          elsif e.eql?('今すぐ')||e.eql?('30分後')||e.eql?('１時間後')
            req = Request.find_by(user_id: user.id)
            req.update(time: e)
            message = {
              type: 'text',
              text: '何かご要望はありますか？<br>ない場合は「なし」とある場合は「要望（例）個室＆掘りごたつ」のように要望という言葉を先頭に入れて入力してください'
            }
            client.reply_message(event['replyToken'], message)

          elsif e.eql?('なし')||e.include?('要望')
            req = Request.find_by(user_id: user.id)
            req.update(hope: e)
            category = Category.find_by(id: req.category_id)
            client.reply_message(event['replyToken'], template4)
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

  def template3
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "時間",
          "text": "開始時刻を選んでください",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg"
          },
          "actions": [
              {
                "type": "postback",
                "label": "今すぐ",
                "data": "now",
                "text": "今すぐ"
              },
              {
                "type": "postback",
                "label": "30分後",
                "data": "30later",
                "text": "30分後"
              },
              {
                "type": "postback",
                "label": "１時間後",
                "data": "60later",
                "text": "１時間後"
              }
          ]
      }
    }
  end

  def template4
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "ありがとうございます。<br>リクエストが完成しました<br>ジャンル： "+category.name +"<br>
          予算： "+ req.budget + "<br>人数： "+ req.number_of_people.to_s +"<br>開始時間： "+ req.time +"<br>要望"+　req.hope+ "<br><br>確認できましたか？",
          "actions": [
              {
                "type": "message",
                "label": "OK!",
                "text": "OK"
              },
              {
                "type": "message",
                "label": "修正",
                "text": "修正"
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
