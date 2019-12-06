class Api::V1::Admin::LogsController < ApplicationController
  before_action :authorize_request
  before_action :find_log,   only: %i[destroy update]
  before_action :get_user,   only: %i[check_in check_out create report]
  before_action :admin_only?

  def check_in
    user = get_user

    @log = Log.new(check_in: log_params[:check_in], user_id: user.id)

    if @log.save
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @log
    end
  end

  def check_out
    user = get_user

    @log = user.logs.last

    unless @log.check_out.nil?
      raise ExceptionHandler::InvalidLog, "User #{user.id_number} already left the office please contact your manager to fix logs"
    end

    if @log.update!(check_out: log_params[:check_out])
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @user
    end
  end

  def report
    user = get_user

    report = user.report(start_day: log_params[:start_day], end_day: log_params[:end_day])

    json_response(object: report)
  end

  def create
    user = get_user

    @log = Log.new(
      check_in:  params[:check_in],
      check_out: params[:check_out],
      user_id:   user.id
    )

    if @log.save
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @log
    end
  end

  def update
    if @log.update!(log_info)
      head :ok
    else
      raise ActiveRecord::RecordInvalid, @log
    end
  end

  def destroy
    @log.destroy

    head :ok
  end

  private

  def log_params
    params.permit(
      :check_in,
      :check_out,
      :id_number,
      :start_day,
      :end_day
    )
  end

  def log_info
    log_info = log_params
    log_info.delete("id_number")

    log_info
  end

  def find_log
    @log ||= Log.find(params[:id])
  end

  def get_user
    user = User.find_by(id_number: log_params[:id_number])

    if user.nil?
      raise ActiveRecord::RecordNotFound, "Couldn't find User with 'id_number'=#{params[:id_number]}"
    end

    user
  end
end
