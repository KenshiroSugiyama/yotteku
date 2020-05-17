class FirebaseController < ApplicationController
  def create
    if decoded_token = authenticate_firebase_id_token
      user = yield(decoded_token)
      log_in(user)
      flash[:success] = 'ログインしました。'
      redirect_back_or(users_path)
    else
      flash[:danger] = 'ログインできませんでした。'
      redirect_to login_url
    end
  end

  def login
  end
end
