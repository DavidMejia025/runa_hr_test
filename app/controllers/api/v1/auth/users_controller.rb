class Api::V1::Auth::UsersController < ApplicationController
  skip_before_action :authorize_request

  def login
    @user = User.find_by(id_number: auth_params[:id_number])

    if @user&.authenticate(auth_params[:password])
      token = JwtService.encode(payload: {user_id: @user.id})
      time  = Time.now + 24.hours.to_i

      json_response(object: build_response(token: token, time: time))
    else
      raise(ExceptionHandler::AuthenticationError, "invalid_credentials")
    end
  end

  private

  def auth_params
    params.permit(
      :name,
      :last_name,
      :id_number,
      :password,
      :department,
      :position
    )
  end

  def build_response(token:, time:)
    {
      token:     token,
      exp:       time.strftime("%m-%d-%Y %H:%M"),
      id_number: @user.id_number
    }
  end
end
