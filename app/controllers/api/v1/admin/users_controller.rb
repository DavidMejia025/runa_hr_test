class Api::V1::Admin::UsersController < ApplicationController
  before_action :authorize_request
  before_action :find_user,  except: %i[create index]
  before_action :admin_only?

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

  def user_params
   params.require(:user).permit(
     :name,
     :last_name,
     :id_number,
     :password,
     :department,
     :position,
     :role
   )
 end
end
