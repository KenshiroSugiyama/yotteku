class RestaurantInformationController < ApplicationController
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
            flash[:notice] = '登録しました'
        else
            redirect_to action: "new"
            flash[:alert] = '登録に失敗しました'
        end
    end

    def show
        @info = RestaurantInformation.find(params[:id])
    end
end
