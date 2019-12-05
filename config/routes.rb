# == Route Map
#
#                      Prefix Verb   URI Pattern                                                                              Controller#Action
#                        root GET    /                                                                                        homepage#index
#           api_v1_auth_login POST   /api/v1/auth/login(.:format)                                                             api/v1/auth/users#login
# api_v1_user_update_password PUT    /api/v1/users/:user_id/update_password(.:format)                                         api/v1/users#update_password
#          api_v1_user_report GET    /api/v1/users/:user_id/report(.:format)                                                  api/v1/users#report
#                api_v1_users GET    /api/v1/users(.:format)                                                                  api/v1/users#index
#                             POST   /api/v1/users(.:format)                                                                  api/v1/users#create
#                 api_v1_user GET    /api/v1/users/:id(.:format)                                                              api/v1/users#show
#                             PATCH  /api/v1/users/:id(.:format)                                                              api/v1/users#update
#                             PUT    /api/v1/users/:id(.:format)                                                              api/v1/users#update
#                             DELETE /api/v1/users/:id(.:format)                                                              api/v1/users#destroy
#           api_v1_admin_logs POST   /api/v1/admin/logs(.:format)                                                             api/v1/admin/logs#create
#            api_v1_admin_log DELETE /api/v1/admin/logs/:id(.:format)                                                         api/v1/admin/logs#destroy
#    api_v1_admin_logs_report GET    /api/v1/admin/logs/report(.:format)                                                      api/v1/admin/logs#report
#  api_v1_admin_logs_check_in POST   /api/v1/admin/logs/check_in(.:format)                                                    api/v1/admin/logs#check_in
# api_v1_admin_logs_check_out POST   /api/v1/admin/logs/check_out(.:format)                                                   api/v1/admin/logs#check_out
#          rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#   rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#          rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#   update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#        rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

Rails.application.routes.draw do
  root 'homepage#index'

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "login",  to: "users#login"
      end

      resources :users, only: %i[index show update create destroy] do
        put "update_password", to: "users#update_password"

        get  'report',    to: "users#report"
      end

      namespace :admin do
        resources :logs, only: %i[create destroy]

        get  'logs/report',    to: "logs#report"
        post 'logs/check_in',  to: "logs#check_in"
        post 'logs/check_out', to: "logs#check_out"
      end
    end
  end
end
