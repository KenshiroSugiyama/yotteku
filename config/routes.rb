Rails.application.routes.draw do
  #杉山追加------------------------------------------------------
  devise_for :restaurants, :controller => {
    :registrations => 'restaurants/registrations',
    :sessions => 'restaurants/sessions'   
  } 

  devise_scope :restaurants do
    get "restaurants/:id", :to => "users/registrations#detail"
    get "signup", :to => "restaurants/registrations#new"
    get "login", :to => "restaurants/sessions#new"
    get "logout", :to => "restaurants/sessions#destroy"
  end
  #--------------------------------------------------------------
  get 'restaurant/signup'
  get 'restaurant/login'
  get 'reserve/edit'
  get 'reserve/update'
  get 'chat/index'
  get 'users_restaurants/new'
  get 'users_restaurants/create'
  get 'users_restaurants/edit'
  get 'users_restaurants/update'
  get 'users_restaurants/mypage'
  get 'users_restaurants/detail'
  get 'user_profile/show'
  get 'user_profile/new'
  get 'user_profile/edit'
  get 'user_profile/create'
  get 'user_profile/update'
  get 'request_controller/new'
  get 'user_profile/show'
  get 'user/login'
  get '/' => 'firebase#login-authUI'
  get 'firebase/after-login' =>'firebase#after-login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
