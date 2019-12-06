class Api::V1::Auth::UsersController < ApplicationController
  skip_before_action :authorize_request
  before_action :find_user

  def login
    if @user&.authenticate(auth_params[:password])
      token = create_token
      time  = set_time
      json_response(object: build_response(token: token, time: time))
    else
      raise(ExceptionHandler::AuthenticationError, "invalid_credentials")
    end
  end

  private

  def auth_params
    params.permit(
      :id_number,
      :password,
    )
  end

  def create_token
    JwtService.encode(payload: {user_id_number: @user.id_number})
  end

  def find_user
    @user = User.find_by(id_number: auth_params[:id_number])

    if @user.nil?
      raise ActiveRecord::RecordNotFound, "Couldn't find User with id_number=#{params[:id_number]}"
    end
  end

  def set_time(time: Time.now)
    @time = Time.now + 24.hours.to_i\
  end

  def build_response(token:, time:)
    {
      token:     token,
      exp:       time.strftime("%m-%d-%Y %H:%M"),
      id_number: @user.id_number
    }
  end
end
