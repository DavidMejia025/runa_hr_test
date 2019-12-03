module Response
  def json_response(object:, status: :ok)
    render json: object.to_json, status: status
  end

  def build_user_response(user:)
    {
      user: {
        name:       user.name,
        last_name:  user.last_name,
        id_number:  user.id_number,
        department: user.department,
        position:   user.position
      }
    }
  end
end
