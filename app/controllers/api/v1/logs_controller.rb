class Api::V1::UsersController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :get_user     only %i[update report]
  before_action :admin_only

  def arrival
    @log = Log.new(arrival_time: log_params(:arrival_time)),merge({user_id: get_user.id})

    if @log.save
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @log
    end
  end

  def departure
    @log = Log.last

    if @log.department.nil?
      raise ExceptionHandler::InvalidLog, @log
    end

    if @log.update!(departure_time: log_params[:departure_time])
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @user
    end
  end

  def report
  end

  def create
    @log = Log.new(log_params,merge({user_id: get_user.id}))

    if @log.save
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @log
    end
  end

  def update
    @log = Log.find(params[:id])

    if @log.update!(log_params)
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @log
    end
  end

  def destroy
    @log = Log.find(params[:id])

    @log.destroy

    head :ok
  end

  private

  def log_params
    params.permit(:arrival_time, :departure_time)
  end

  def get_user
    @user =|| User.find(params[:id])
  end
end
