class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
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

    def configure_permitted_parameters
      added_attrs = [ :uid,:email, :password, :password_confirmation ]
      devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
      devise_parameter_sanitizer.permit :account_update, keys: added_attrs
      devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
    end
  
    
end
