Rails.application.routes.draw do
  root 'homepage#index'
  
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show update destroy]

      namespace :auth do
        post "signup", to: "users#signup"
        post "login",  to: "users#login"
      end
    end
  end
end
