class LinebotController < ApplicationController
    require 'line/bot'
    
    protect_from_forgery :except => [:callback]

  def hope  
    @scout_template = ScoutTemplate.where(restaurant_id: params[:res_id])
  end

  def scout_ajax
    scout_template = ScoutTemplate.find(params[:id])
    render json: scout_template
  end

  def responce
    user = Request.find(params[:req_id]).user_id
    userId = User.find(user).uid
    @res = Restaurant.find(params[:res_id])
    # @res_info = RestaurantInformation.find_by(restaurant_id: @res.id)
    #scoutインスタンス生成
    req = Request.find(params[:req_id])
    
    unless req.status
      @scout = Scout.new
      @scout.restaurant_id = params[:res_id]
      @scout.request_id = params[:req_id]
      @scout.price = params[:price]
      @scout.beer = params[:beer]
      @scout.start_time = params[:start_time]
      @scout.drink_time = params[:drink_time]
      @scout.content = params[:content]
      @scout.hope = params[:hope]

      if @scout.save
        def recieve_scout
          {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "#{@res.name}  からスカウトが届きました！\b\n\b\n以下の「内容確認」ボタンを押して詳しいスカウト内容をご確認ください。\b\n予約を確定する場合は、「予約確定」ボタンを押して下さい。",
                "actions": [
                    {
                      "type": "uri",
                      "label": "内容確認",
                      "uri": "https://yotteku.herokuapp.com/scout_confirm?scout_id=#{@scout.id}"
                    },
                    {
                      "type": "message",
                      "label": "予約確定",
                      "text": "予約確定,#{@res.name},#{@scout.id}",
                    }
                ]
            }
          }
        end
        client.push_message(userId,recieve_scout)
        redirect_to scout_confirm_path(scout_id: @scout.id)
        flash[:success] = 'スカウトメッセージを送信しました！ブラウザを閉じて、Lineの画面へお戻り下さい。'
      end
    else
      message = {
        "type": "text",
        "text": "他の店との予約が先に成立していたため、スカウトメッセージの送信に失敗しました。"
      }
      client.push_message(userId,message)
    end
  end

  def scout_confirm
    @scout = Scout.find(params[:scout_id])
    @res = Restaurant.find(@scout.restaurant_id)
    @res_info = RestaurantInformation.find_by(restaurant_id: @res.id)
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Follow
        uid = event['source']['userId']
        user = User.find_by(uid: uid)
        unless user
          message = {
            "type": "text",
            "text": "ユーザー登録を以下のリンクよりお願いいたします。\b\nhttps://yotteku.herokuapp.com/users/new?uid=#{uid}"
          }
          client.reply_message(event['replyToken'], message)
        end
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          e = event.message['text']
          num = [*1..100]
          res_category = ['肉系店','魚介系店','イタリアン店']
          req_category = ['肉系','魚介系','イタリアン']
          req_num = ['１～４人','５～８人','９～１２人','１３人以上']
          
          #user作成
          uid = event['source']['userId']
          user = User.find_by(uid: uid)
          if user
            @req = Request.find_by(user_id: user.id)
          else 
            message = {
              "type": "text",
              "text": "ユーザー登録が完了していません！以下のリンクよりユーザー登録をお願いします。\b\nhttps://yotteku.herokuapp.com/users/new?uid=#{uid}"
            }
            client.reply_message(event['replyToken'], message)
            exit
          end
          if e.eql?('リクエスト作成')
            if !@req
              client.reply_message(event['replyToken'], template)
            elsif @req.status
              if (Time.zone.now - @req.updated_at).floor / 3600  < 2 # 時間
                message = {
                  "type": "text",
                  "text": "予約確定からの時間が短いためリクエストを作成できません。予約のキャンセルは、画面下のメニューからお願いします。"
                }
                client.reply_message(event['replyToken'], message)
              else
                @req.update(req_status: false,res_id: nil,status: false,scout_id: nil,hope: "なし")
                client.reply_message(event['replyToken'], template)
              end
            else
              @req.update(req_status: false,hope: "なし")
              client.reply_message(event['replyToken'], template)
            end
          elsif req_category.any?(e)
            category = Category.find_by(name: e)     
            unless @req   
             Request.create(user_id: user.id,category_id: category.id)
            end
            client.reply_message(event['replyToken'], select_freedrink)            
          elsif e.eql?('飲み放題') 
            @req.update(freedrink: e)
            client.reply_message(event['replyToken'], budget)
          # elsif e.eql?('９０分') || e.eql?('１２０分')
          #   @req.update(drinktime: e)
          #   client.reply_message(event['replyToken'], select_foodamount)
          elsif e.eql?('単品') 
            @req.update(freedrink: e)
            client.reply_message(event['replyToken'], budget)
          # elsif e.eql?('がっつり') || e.eql?('少し')
          #   @req.update(foodamount: e)
          #   client.reply_message(event['replyToken'], select_situation)
          # elsif e.eql?('がやがや') || e.eql?('静か')
          #   @req.update(situation: e)
          #   client.reply_message(event['replyToken'], budget)
          elsif e.include?('~2000円') || e.include?('2000~3000円') || e.include?('3000~4000円') || e.include?('5000円~') 
            @req.update(budget: e)
            client.reply_message(event['replyToken'], template7)
          elsif req_num.any?(e)
            a = [0,1,2]
            if a.any?{|v| req_num[v]==e}
              if req_num[0] == e
                v = 0
              elsif req_num[1] == e
                v = 1
              elsif req_num[2] == e
                v = 2
              end
              client.reply_message(event['replyToken'], template8(v))
            else
              message = {
                "type": "text",
                "text": "人数を数字のみ入力してください（例： １３）"
              }
              client.reply_message(event['replyToken'], message)
            end
          elsif num.any?(e.to_i)
            @req.update(number_of_people: e.to_i)
            client.reply_message(event['replyToken'], confirm_hope)
          # elsif e.eql?('今すぐ') || e.eql?('３０分後') || e.eql?('１時間後')
          #   @req.update(time: e)
          #   client.reply_message(event['replyToken'], confirm_hope)
          elsif e.eql?('なし') 
            @req.update(hope: e)
            @category = Category.find(@req.category_id)
            client.reply_message(event['replyToken'], confirm_send_request)
          elsif e.eql?('リクエスト確認')
            if @req.req_status && (Time.zone.now - @req.updated_at).floor / 3600  < 2
              @category = Category.find(@req.category_id)
              client.reply_message(event['replyToken'], confirm_request)
            else
              message = {
              "type": "text",
              "text": "リクエストが見つかりません。リクエストを作成してください"
              }
              client.reply_message(event['replyToken'], message)
            end
          elsif e.eql?('リクエストキャンセル') 
            if @req.status
              message = {
                "type": "text",
                "text": "予約が確定しているリクエストがあります。予約をキャンセルする場合は、「予約確認・キャンセル」よりお願いします。"
              }
              client.reply_message(event['replyToken'], message)
            elsif @req.req_status
              client.reply_message(event['replyToken'], req_cancel)
            else
              message = {
                "type": "text",
                "text": "リクエストを削除しました。「リクエスト作成」を押して、リクエストを最初から作り直してください。"
              }
              scouts = Scout.where(request_id: @req.id)
              scouts.destroy_all
              @req.update(req_status: false,hope: "なし",res_id: nil,scout_id: nil)
              client.reply_message(event['replyToken'], message)
            end
          elsif e.eql?('はい')
            @req.update(req_status: false,hope: "なし",res_id: nil,scout_id: nil)
            message = {
              "type": "text",
              "text": "リクエストを取り消しました。「リクエスト作成」を押して、リクエストを最初から作り直してください。"
            }
            client.reply_message(event['replyToken'], message)
          elsif e.eql?('予約キャンセル') 
            client.reply_message(event['replyToken'], cancel_confirm)
          elsif e.eql?('予約キャンセル確定')
            res = Restaurant.find(@req.res_id)
            message = {
              "type": "text",
              "text": "店側に電話をお願いします。\b\n#{res.phone_number}"
            }
            client.reply_message(event['replyToken'], message)
            @req.update(status: false,req_status: false,hope: "なし",res_id: nil,scout_id: nil)
          elsif e.eql?('OK!')           
            @req.update(req_status: true)
            #ユーザ－に送信
            message = {
              "type": "text",
              "text": "リクエストを店に送信しました。返事をお待ちください"
            }
            client.reply_message(event['replyToken'], message)

             #店側に送信
             res_ids = Restaurant.where(category_id: @req.category_id).pluck(:uid)
             client.multicast(res_ids,res_message)
          elsif e.include?('予約確定')
            a = e.split(",")
            @res = Restaurant.find_by(name: a[1])
            @res_info = RestaurantInformation.find_by(restaurant_id: @res.id)
            @req.update(status: true,res_id: @res.id,scout_id: a[2].to_i)
            scout = Scout.where.not(id: a[2].to_i).where(request_id: @req.id)
            scout.destroy_all
            @scout = Scout.find(a[2].to_i)
            @scout.update(request_id: @req.id)
            message = {
              "type": "text",
              "text": "予約を確定しました！\r\n\r\n店名： #{@res.name}\r\nTel:  #{@res.phone_number}\r\n住所： #{@res_info.address}\r\nurl： #{@res_info.url}\r\n人数： #{@req.number_of_people.to_s}\r\n開始時間： #{@scout.start_time}\r\n値段： #{@scout.price}円\r\nお酒： #{@scout.beer}\r\n内容：\b\n#{@scout.content}\b\n\b\nよってくをご利用頂きありがとうございます！！"
            }
            client.reply_message(event['replyToken'], message)

            #店側に送信
            @user = User.find(@req.user_id)
            def restaurant_template
              {
                "type": "template",
                "altText": "this is a confirm template",
                "template": {
                    "type": "confirm",
                    "text": "予約が成立しました！\r\n予約者名： #{@user.name}\r\nTel:  #{@user.email}\r\n人数： #{@req.number_of_people.to_s}\r\n開始時間： #{@scout.start_time}\r\n値段： #{@scout.price}円\r\nお酒： #{@scout.beer}\r\n内容： #{@scout.content}",
                    "actions": [
                        {
                          "type": "uri",
                          "label": "内容確認",
                          "uri": "https://yotteku.herokuapp.com/scout_confirm?scout_id=#{@scout.id}"
                        },
                        {
                          "type": "message",
                          "label": "OK",
                          "text": "OK",
                        }
                    ]
                }
              }
            end
            client.push_message(@res.uid,restaurant_template)
          elsif e.eql?('予約確認') 
            if @req.status
              @res = Restaurant.find(@req.res_id)
              @res_info = RestaurantInformation.find_by(restaurant_id: @res.id)
              @scout = Scout.find_by(restaurant_id: @res.id,request_id: @req.id)
              client.reply_message(event['replyToken'], reserve_confirm)
            else
              message = {
                "type": "text",
                "text": "成立した予約が見つかりません。リクエストを作成し予約を確定させてください"
                }
              client.reply_message(event['replyToken'], message)
            end
          elsif e.include?('スカウト')
            unless @req.status
              @res = Restaurant.find_by(uid: uid)
              @req_id = e.delete("スカウト").to_i
              message = {
                "type": "text",
                "text": "以下のリンクからスカウトメッセージを送ってください！\b\n https://yotteku.herokuapp.com/hope?res_id=#{@res.id}&req_id=#{@req_id}"
              }
            else
              message = {
                "type": "text",
                "text": "他の店との予約が先に成立したため、スカウトメッセージを送れません。"
              }
            end
            client.reply_message(event['replyToken'], message)
          elsif e.eql?('見送り')
            message = {
              "type": "text",
              "text": "リクエストを見送りました！"
            }
            client.reply_message(event['replyToken'], message)
          elsif e.eql?('店側操作')
            @res = Restaurant.find_by(uid: uid)
            unless @res
              message = {
                "type": "text",
                "text": "店舗登録を以下のリンクよりお願いいたします。\b\nhttps://yotteku.herokuapp.com/restaurants/sign_up?uid=#{uid}"
              }
              client.reply_message(event['replyToken'], message)
            else
              @res_info = RestaurantInformation.find_by(restaurant_id: @res.id)
              client.reply_message(event['replyToken'], restaurant)
            end
          elsif e.eql?('管理者')
            message = {
                "type": "text",
                "text": "https://yotteku.herokuapp.com/admin"
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

  def budget
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

  def select_time
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
                "label": "３０分後",
                "data": "30later",
                "text": '３０分後'
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

  def select_drink_time
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
          "text": "飲み放題の時間は？",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg"
          },
          "actions": [
              {
                "type": "postback",
                "label": "９０分",
                "data": "９０分",
                "text": "９０分"
              },
              {
                "type": "postback",
                "label": "１２０分",
                "data": "１２０分",
                "text": "１２０分"
              }
          ]
      }
    }
  end

  def select_situation
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "雰囲気",
          "text": "店の雰囲気は？",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg"
          },
          "actions": [
              {
                "type": "postback",
                "label": "がやがや",
                "data": "がやがや",
                "text": "がやがや"
              },
              {
                "type": "postback",
                "label": "静か",
                "data": "静か",
                "text": '静か'
              }
          ]
      }
    }
  end

  def select_freedrink
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXRQvfA_RhFpqGEWrDb3MxzHrWmjFT8gjRyw&usqp=CAU",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "飲み放題",
          "text": "お酒は？",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXRQvfA_RhFpqGEWrDb3MxzHrWmjFT8gjRyw&usqp=CAU"
          },
          "actions": [
              {
                "type": "postback",
                "label": "飲み放題",
                "data": "飲み放題",
                "text": "飲み放題"
              },
              {
                "type": "postback",
                "label": "単品",
                "data": "単品",
                "text": '単品'
              }
          ]
      }
    }
  end

  def select_foodamount
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "食べ物の量",
          "text": "がっつり食べたい？",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg"
          },
          "actions": [
              {
                "type": "postback",
                "label": "がっつり",
                "data": "がっつり",
                "text": "がっつり"
              },
              {
                "type": "postback",
                "label": "少しでいい",
                "data": "少し",
                "text": '少し'
              }
          ]
      }
    }
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

  def confirm_request
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "リクエスト確認\r\nジャンル： #{@category.name}\r\nお酒： #{@req.freedrink}\r\n予算： #{@req.budget}\r\n人数： #{@req.number_of_people.to_s}\r\n開始時間： #{@req.time}\r\n要望:  #{@req.hope}",
          "actions": [
              {
                "type": "message",
                "label": "OK",
                "text": "OK"
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

  
  
  def confirm_hope
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "何かご要望はありますか？（例： 掘りごたつ＆個室、飲み放題付きで！）",
          "actions": [
              {
                "type": "uri",
                "label": "要望を入力",
                "uri": "https://yotteku.herokuapp.com/request_controller/edit?id=#{@req.id}"
              },
              {
                "type": "message",
                "label": "なし",
                "text": "なし"
              }
          ]
      }
    }
  end

  def req_cancel
    {
      "type": "template",
      "altText": "リクエストをキャンセルしますか？",
      "template": {
          "type": "confirm",
          "text": "すでに店側に送信しているリクエストが存在します。リクエストを作り直しますか？",
          "actions": [
              {
                "type": "message",
                "label": "はい",
                "text": "はい"
              },
              {
                "type": "message",
                "label": "いいえ",
                "text": "いいえ"
              }
          ]
      }
    }
  end


  
  def template7
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://imgcp.aacdn.jp/img-a/1200/900/aa/gm/article/4/7/2/1/9/2/201712101304/topimg_original.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "人数",
          "text": "人数を選択してください",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://imgcp.aacdn.jp/img-a/1200/900/aa/gm/article/4/7/2/1/9/2/201712101304/topimg_original.jpg"
          },
          "actions": [
              {
                "type": "postback",
                "label": "1～4人",
                "data": "1..4",
                "text": "１～４人"
              },
              {
                "type": "postback",
                "label": "5～8人",
                "data": "5..8",
                "text": "５～８人"
              },
              {
                "type": "postback",
                "label": "9～12人",
                "data": "9..12",
                "text": "９～１２人"
              },
              {
                "type": "postback",
                "label": "13人以上",
                "data": "13.. ",
                "text": "１３人以上"
              }  
          ]
      }
    }
  end

  def template8(v)
    if v == 0
      req = ['1','2','3','4']
    elsif v == 1
      req = ['5','6','7','8']
    elsif v == 2
      req = ['9','10','11','12']
    end

    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "人数",
          "text": "人数を選択してください",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg"
          },
          "actions": [
              {
                "type": "postback",
                "label": "#{req[0]}",
                "data": "#{req[0]}",
                "text": "#{req[0]}"
              },
              {
                "type": "postback",
                "label": "#{req[1]}",
                "data": "#{req[1]}",
                "text": "#{req[1]}"
              },
              {
                "type": "postback",
                "label": "#{req[2]}",
                "data": "#{req[2]}",
                "text": "#{req[2]}"
              },
              {
                "type": "postback",
                "label": "#{req[3]}",
                "data": "#{req[3]}",
                "text": "#{req[3]}"
              }
          ]
      }
    }
  end
  def template9
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "人数",
          "text": "人数を選択してください",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg"
          },
          "actions": [
              {
                "type": "postback",
                "label": "1人",
                "data": "1",
                "text": "1"
              },
              {
                "type": "postback",
                "label": "2人",
                "data": "2",
                "text": "2"
              },
              {
                "type": "postback",
                "label": "3人",
                "data": "3",
                "text": "3"
              },
              {
                "type": "postback",
                "label": "4人",
                "data": "4",
                "text": "4"
              }  
          ]
      }
    }
  end

  def res_message
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "リクエストが届きました！\r\n予算： #{@req.budget}\r\n人数： #{@req.number_of_people.to_s}\r\n開始時間： #{@req.time}\r\nお酒： #{@req.freedrink}\r\n要望:  #{@req.hope}",
          "actions": [
              {
                "type": "message",
                "label": "スカウト送信",
                "text": "スカウト#{@req.id}",
              },
              {
                "type": "message",
                "label": "見送り",
                "text": "見送り"
              }
          ]
      }
    }
  end

  def reserve_confirm
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "#{@res.name}\r\nTel: #{@res.phone_number}\r\n住所： #{@res_info.address}\r\nurl： #{@res_info.url}\r\n人数： #{@req.number_of_people.to_s}\r\n開始時間： #{@scout.start_time}\r\n値段： #{@scout.price}円\r\nお酒： #{@scout.beer}\r\n内容： #{@scout.content}",
          "actions": [
              {
                "type": "message",
                "label": "OK",
                "text": "OK",
              },
              {
                "type": "message",
                "label": "キャンセル",
                "text": "予約キャンセル"
              }
          ]
      }
    }
  end

  def restaurant
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "店側メニュー",
          "text": "何かお困りですか？",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "https://www.gurutto-fukushima.com/db_img/cl_img/800/menu/menu_img_20181009130238470.jpg"
          },
          "actions": [
              {
                "type": "uri",
                "label": "予約一覧",
                "uri": "https://yotteku.herokuapp.com/reserves?id=#{@res.id}"
              },
              {
                "type": "uri",
                "label": "登録情報編集",
                "uri": "https://yotteku.herokuapp.com/restaurant_information/#{@res_info.id}"
              },
              {
                "type": "uri",
                "label": "スカウトテンプレ作成",
                "uri": "https://yotteku.herokuapp.com/scout_templates?res_id=#{@res.id}"
              }
          ]
      }
    }
  end


  def cancel_confirm
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "予約を本当にキャンセルしますか？",
          "actions": [
              {
                "type": "message",
                "label": "はい",
                "text": "予約キャンセル確定",
              },
              {
                "type": "message",
                "label": "いいえ",
                "text": "OK"
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
