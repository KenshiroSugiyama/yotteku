class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    @user = User.new
    @user.uid = params[:user][:uid]
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    if @user.save
      flash[:success] = "登録成功！"
      redirect_to user_path(@user.id)
    else
      flash.now[:danger] = "登録に失敗しました"
      render :new
    end
  end

  def index
    @user = User.all
  end 

  def show
    @user = User.find(params[:id])
  end
end
