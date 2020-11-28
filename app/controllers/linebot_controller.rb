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
          if e.eql?('講師検索')
            client.reply_message(event['replyToken'], template100)
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

  def template100
    {
      "type": "template",
      "altText": "講師を選択してください",
      "template": {
          "type": "carousel",
          "text": "講師を選択してください",
          "columns": [
          {
            "thumbnailImageUrl": "https://pbs.twimg.com/media/BRNdNatCEAAWeiO.jpg",
            "imageBackgroundColor": "#FFFFFF",
            "title": "堅志郎",
            "text": "工学部3年\r\n得意教科　物理\r\n趣味　釣り",
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
            "thumbnailImageUrl": "data:image/jpeg;base64,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",
            "imageBackgroundColor": "#000000",
            "title": "和",
            "text": "工学部4年\r\n得意教科　数学\r\n趣味　パソコン",
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
            "thumbnailImageUrl": "https://nanasepn.com/wp-content/uploads/2019/06/noname.png",
            "imageBackgroundColor": "#000000",
            "title": "そらたろう",
            "text": "法科大学院2年\r\n得意教科　英語\r\n趣味　酒",
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
