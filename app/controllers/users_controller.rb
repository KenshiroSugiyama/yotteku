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
      redirect_to user_path(@user.id)
    end
  end

  def show
    @user = User.find(params[:id])
  end
end
