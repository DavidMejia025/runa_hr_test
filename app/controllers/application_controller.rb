class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include ErrorMessages

  before_action :authorize_request, except:  %i[login signup]


  def authorize_request
    header = request.headers['Authorization']

    if header
      header = header.split(' ').last
    else
      raise(ExceptionHandler::MissingToken)
    end

    begin
      @decoded = JwtService.decode(token: header)

      @current_user = User.find(@decoded["user_id"])
    end
  end

  def admin_only?
    return true if @current_user&.admin?

    raise ExceptionHandler::AuthenticationError, "#{not_an_admin}"
  end
end
