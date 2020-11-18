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
        phone_number = params[:restaurant_information][:phone_number]

        if @info.save(res_info_params)
            Restaurant.find(current_restaurant.id).update(name: name,phone_number: phone_number,category_id: category_id)
            flash[:notice] = '登録しました!Lineの画面にお戻り下さい。'
            redirect_to restaurant_information_path(id: @info.id)
        end
    end

    def edit
        @info = RestaurantInformation.find(params[:id])
    end
    
    def update
        @info = RestaurantInformation.find(params[:id])
        @info.menu = params[:restaurant_information][:menu]
        @info.price_min = params[:restaurant_information][:price_min]
        @info.price_max = params[:restaurant_information][:price_max]
        @info.address = params[:restaurant_information][:address]
        @info.url = params[:restaurant_information][:url]
        if @info.update(res_info_params)
            flash[:success] = '更新しました!'
            redirect_to restaurant_information_path(id: @info.id)
        else
            flash[:danger] = '更新に失敗しました'
            redirect_to edit_restaurant_information_path(id: @info.id)
        end
    end

    def show
        @info = RestaurantInformation.find(params[:id])
        @res = Restaurant.find(@info.restaurant_id)
    end

    private
    def res_info_params
        params.require(:restaurant_information).permit(:menu, :price_max,:price_min,:address,:url)
        params.permit(:id)
    end
end
