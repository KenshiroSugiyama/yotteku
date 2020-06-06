class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper

  private
    # tokenが正規のものであれば、デコード結果を返す
    # そうでなければfalseを返す
    def authenticate_firebase_id_token
      # authenticate_with_http_tokenは、HTTPリクエストヘッダーに
      # Authorizationが含まれていればブロックを評価する。
      # 含まれていなければnilを返す。
      authenticate_with_http_token do |token, options|
        begin
          decoded_token = FirebaseHelper::Auth.verify_id_token(token)
        rescue => e
          logger.error(e.message)
          false
        end
      end
    end
    
    # ログイン後のリダイレクト先
    def after_sign_in_path_for(resource_or_scope)
      if resource_or_scope.is_a?(Restaurant)
        res = RestaurantInformation.find_by(restaurant_id: resource_or_scope.id)
        unless res
          new_restaurant_information_path(restaurant_id: resource_or_scope.id)
        else
          restaurant_information_path(id: res.id )
        end
      else
        root_path
      end
    end
  
    
end
