class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include ErrorMessages

  before_action :authorize_request, except:  %i[login signup]

  def authorize_request
    puts ".....................................00"
    puts request
    puts ".....................................hola"
    header = request.headers['Authorization']

    if header
      puts "....................................111"
      header = header.split(' ').last
    else
      puts ".....................................222"
      raise(ExceptionHandler::MissingToken)
    end

    begin
      puts ".....................................333"
      @decoded = JwtService.decode(token: header)

      @current_user = User.find(@decoded["user_id"])
    end
  end

  def admin_only?
    return true if @current_user&.admin?

    raise ExceptionHandler::AuthenticationError, "#{not_an_admin}"
  end
end
