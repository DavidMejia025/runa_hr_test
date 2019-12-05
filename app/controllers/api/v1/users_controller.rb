class Api::V1::UsersController < ApplicationController
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
    if @user.update!(user_params)
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @user
    end
  end

  def update_password
    user = User.find_by(id_number: user_params[:id_number])

    unless user&.authenticate(user_params[:password])
      raise(ExceptionHandler::AuthenticationError, "invalid_credentials")
    end

    unless user_params[:new_password] == user_params[:new_password_confirmation]
      raise(ExceptionHandler::AuthenticationError, "new password confirmation failed")
    end

    if user.update!(password: user_params[:new_password])
      head :ok
    else
      raise ActiveRecord::RecordInvalid, user
    end
  end

  def destroy
    @user.destroy

    head :ok
  end

  private

  def find_user
    @user ||= User.find(params[:id])
  end

  def user_params
    params.permit(
      :name,
      :last_name,
      :id_number,
      :password,
      :department,
      :position,
      :role,
      :new_password,
      :new_password_confirmation
    )
  end
end
