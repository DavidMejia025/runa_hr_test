module Response
  def json_response(object:, status: :ok)
    render json: object.to_json, status: status
  end
end
