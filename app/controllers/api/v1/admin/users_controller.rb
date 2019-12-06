class Api::V1::Admin::UsersController < ApplicationController
  before_action :authorize_request
  before_action :find_user,   only:   %i[show update destroy]
  before_action :admin_only?, except: %i[show update_password]

  def create
    @user = User.new(user_params)

    if @user.save
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @user
    end
  end

  def index
    @users = User.all

    users = @users.map do |user|
      build_user_response(user: user)
    end

    json_response(object: users)
  end

  def show
    if @user
      user = build_user_response(user: @user)

      json_response(object: user)
    else
      raise ActiveRecord::RecordInvalid, "User with id + #{params[:id]} was not foud"
    end
  end

  def update
    update_user_params = update_params

    if @user.update!(update_user_params)
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @user
    end
  end

  def destroy
    @user.destroy

    head :ok
  end

  private

  def find_user
    @user ||= User.find_by(id_number: params[:id_number])

    if @user.nil?
      raise ActiveRecord::RecordNotFound, "Couldn't find User with id_number=#{params[:id_number]}"
    end
  end

  def update_params
    return user_params unless user_params[:new_id_number]

     new_user_params = user_params.except(:new_id_number)

     new_user_params[:id_number] = user_params[:new_id_number]

     new_user_params
  end

  def user_params
   params.permit(
     :name,
     :last_name,
     :new_id_number,
     :id_number,
     :password,
     :department,
     :position,
     :role
   )
 end
end
