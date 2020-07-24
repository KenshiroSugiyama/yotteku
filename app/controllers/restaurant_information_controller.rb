class RestaurantInformationController < ApplicationController
    require "net/http"
    require "json"

    def new
        @info = current_restaurant.build_restaurant_information
    end

    def create
        @info = current_restaurant.build_restaurant_information
        @info.menu = params[:restaurant_information][:menu]
        @info.price_min = params[:restaurant_information][:price_min]
        @info.price_max = params[:restaurant_information][:price_max]
        @info.address = params[:restaurant_information][:address]
        @info.url = params[:restaurant_information][:url]
        name = params[:restaurant_information][:name]
        category_id = params[:restaurant_information][:category_id].to_i
        phone_number = params[:restaurant_information][:phone_number].to_i

        if @info.save!
            Restaurant.find(current_restaurant.id).update(name: name,phone_number: phone_number,category_id: category_id)
            redirect_to restaurant_information_path(id: @info.id)
            flash[:notice] = '登録しました!Lineの画面にお戻り下さい。'
            #line push 送信
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
                        "type": "text",
                        "text": "要望入力が完了しました！\r\nジャンル： #{@category.name} \r\n予算： #{@req.budget}\r\n人数： #{@req.number_of_people.to_s}\r\n開始時間： #{@req.time}\r\n要望:  #{@req.hope}"
                    }
                ]
            }
            puts userId
            req = Net::HTTP.new(uri.host, uri.port)
            req.use_ssl = uri.scheme === "https"
            req.post(uri.path, post.to_json,headers)
        else
            redirect_to action: "new"
            flash[:alert] = '登録に失敗しました'
        end
    end

    def show
        @info = RestaurantInformation.find(params[:id])
    end
end
