class Api::V1::Auth::UsersController< ApplicationController
  def login
    @user = User.find_by(id_number: login_params[:id_number])

    if @user&.authenticate(login_params[:password])
      token = JwtService.encode(user_id: @user.id)
      time  = Time.now + 24.hours.to_i

      json_response(object: build_response(token: token, time: time))
    else
      raise(ExceptionHandler::AuthenticationError, invalid_credentials)
    end
  end

  def signup
    @user = User.new(login_params)

    begin
      if @user.save
        token = JwtService.encode(user_id: @user.id)
        time  = Time.now + 24.hours.to_i

        json_response(object: build_response(token: token, time: time), status: :created)
      else
        raise(ActiveRecord::RecordInvalid, @user)
      end
    end
  end

  private

  def login_params
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
