class Api::V1::UsersController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :find_user,  only:   %i[show update]
  before_action :admin_only, except: %i[show create]

  def index
    @users = User.all

    json_response(object: @users)
  end

  def show
    json_response(object: @user)
  end

  def update
    unless @user.update(user_params)
      json_response(
        object: {errors: @user.errors.full_messages },
        status: :unprocessable_entity
      )
    end
  end

  def destroy
    @user.destroy
  end

  private

  def find_user
    begin
      @user = User.find(params[:id])
    end
  end

  def user_params
    params.permit(
      :name,
      :last_name,
      :id_number,
      :password,
      :department,
      :position
    )
  end
end
