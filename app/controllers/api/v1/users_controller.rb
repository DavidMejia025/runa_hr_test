class Api::V1::UsersController < ApplicationController
  before_action :authorize_request
  before_action :find_user
  before_action :user_eq_current_user?

  def show
    if @user
      user = build_user_response(user: @user)

      json_response(object: user)
    else
      raise ActiveRecord::RecordInvalid, "User with id + #{params[:id]} was not foud"
    end
  end

  def update_password
    unless @current_user&.authenticate(user_params[:password])
      raise(ExceptionHandler::AuthenticationError, "invalid_credentials")
    end

    unless user_params[:new_password] == user_params[:new_password_confirmation]
      raise(ExceptionHandler::AuthenticationError, "new password confirmation failed")
    end

    if @current_user.update!(password: user_params[:new_password])
      head :ok
    else
      raise ActiveRecord::RecordInvalid, user
    end
  end

  def report
    report = @current_user.report(start_day: params[:start_day], end_day: params[:end_day])

    json_response(object: report)
  end

  private

  def find_user
    @user ||= User.find_by(id_number: params[:id_number])

    if @user.nil?
      raise ActiveRecord::RecordNotFound, "Couldn't find User with id_number=#{params[:id_number]}"
    end
  end

  def user_eq_current_user?
    unless @current_user == @user
      raise ExceptionHandler::InvalidToken, "token does not corresponds to the user requested information"
    end

    true
  end

  def user_params
    params.permit(
      :id_number,
      :password,
      :new_password,
      :new_password_confirmation
    )
  end
end
