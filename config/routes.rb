Rails.application.routes.draw do
  get 'mypage/home' => 'mypage#home'
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

  resources :restaurant_information,only: [:new,:create,:show,:edit,:update]
  resources :restaurant ,only: [:index,:show]

  resources :scout_templates,only: [:new,:create,:show,:edit,:update,:index]
  
  get 'user_profile/show' => 'user_profile#show'
  get 'user_profile/new' => 'user_profile#new'
  get 'user_profile/edit' =>'user_profile#edit'
  
  get 'request_controller/edit' =>'request_controller#edit'
  put 'request_controller/update' =>'request_controller#update'
  get '/' => 'firebase#login-authUI'
  get 'firebase/after-login' =>'firebase#after-login'

  post '/callback' => 'linebot#callback'
  get '/hope' => 'linebot#hope'
  get '/scout_ajax' => 'linebot#scout_ajax'
  post '/responce' => 'linebot#responce'
  get '/scout_confirm' => 'linebot#scout_confirm'

  #--------------------------------------------------------------
  
  resources :reserves,only: [:index,:show]
  get '/admin' => 'reserves#admin'
  get '/admin_index' => 'reserves#admin_index'
  get '/admin_show' => 'reserves#admin_show'
  get 'chat/index'
  get 'users_restaurants/new'
  get 'users_restaurants/create'
  get 'users_restaurants/edit'
  get 'users_restaurants/update'
  get 'users_restaurants/mypage'
  get 'users_restaurants/detail'
  get 'user_profile/create'
  get 'user_profile/update'
  get 'user_profile/show'
  resources :users,only: [:new,:create,:show,:index]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
