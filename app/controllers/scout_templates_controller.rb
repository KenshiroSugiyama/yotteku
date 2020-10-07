class ScoutTemplatesController < ApplicationController
    def new
        @scout_template = ScoutTemplate.new
    end

    def create
        @scout_template = ScoutTemplate.new
        @scout_template.name = params[:scout_template][:name]
        @scout_template.price = params[:scout_template][:price]
        @scout_template.beer = params[:scout_template][:beer]
        @scout_template.start_time = params[:scout_template][:start_time]
        @scout_template.drink_time = params[:scout_template][:drink_time]
        @scout_template.content = params[:scout_template][:content]
        @scout_template.hope = params[:scout_template][:hope]
        @scout_template.restaurant_id = params[:scout_template][:restaurant_id]
        if @scout_template.save(scout_template_params)
            flash[:success] = "テンプレートを登録しました！"
            redirect_to scout_template_path(id: @scout_template.id)    
        else
            flash[:danger] = "更新に失敗しました。"
            redirect_to new_scout_template_path(res_id: @scout_template.restaurant_id)
        end
    end

    def edit
        @scout_template = ScoutTemplate.find(params[:id])
        @res_id = @scout_template.restaurant_id
    end

    def update
        @scout_template = ScoutTemplate.find(params[:id])
        @scout_template.name = params[:scout_template][:name]
        @scout_template.price = params[:scout_template][:price]
        @scout_template.beer = params[:scout_template][:beer]
        @scout_template.start_time = params[:scout_template][:start_time]
        @scout_template.drink_time = params[:scout_template][:drink_time]
        @scout_template.content = params[:scout_template][:content]
        @scout_template.hope = params[:scout_template][:hope]
        @scout_template.restaurant_id = params[:scout_template][:restaurant_id]
        if @scout_template.update(scout_template_params)
            flash[:success] = "更新しました！"
            redirect_to scout_template_path(id: @scout_template.id)
        else
            flash[:danger] = "更新に失敗しました。"
            redirect_to edit_scout_template_path(id: @scout_template.id)
        end
    end

    def show
        @scout_template = ScoutTemplate.find(params[:id])
        @res = Restaurant.find(@scout_template.restaurant_id)
    end

    def index
        @scout_template = ScoutTemplate.where(restaurant_id: params[:res_id])
        @res = Restaurant.find(params[:res_id])
    end

    private

    def scout_template_params
      params.require(:scout_template).permit(:name, :price,:beer,:start_time,:drink_time,:content,:hope,:restaurant_id)
    end
end
