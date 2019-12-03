# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#                      root GET    /                                                                                        homepage#index
#              api_v1_users GET    /api/v1/users(.:format)                                                                  api/v1/users#index
#                           POST   /api/v1/users(.:format)                                                                  api/v1/users#create
#               api_v1_user GET    /api/v1/users/:id(.:format)                                                              api/v1/users#show
#                           PATCH  /api/v1/users/:id(.:format)                                                              api/v1/users#update
#                           PUT    /api/v1/users/:id(.:format)                                                              api/v1/users#update
#                           DELETE /api/v1/users/:id(.:format)                                                              api/v1/users#destroy
#        api_v1_auth_signup POST   /api/v1/auth/signup(.:format)                                                            api/v1/auth/users#signup
#         api_v1_auth_login POST   /api/v1/auth/login(.:format)                                                             api/v1/auth/users#login
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

Rails.application.routes.draw do
  root 'homepage#index'

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create update destroy]

      namespace :auth do
        post "signup", to: "users#signup"
        post "login",  to: "users#login"
      end
    end
  end
end
