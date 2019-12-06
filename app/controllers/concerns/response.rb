module Response
  def json_response(object:, status: :ok)
    render json: object.to_json, status: status
  end

  def build_user_response(user:)
    user_response = {
      name:       user.name,
      last_name:  user.last_name,
      id_number:  user.id_number,
      department: user.department,
      position:   user.position
    }

    if user.admin?
      user_response.merge!({ role: user.role})
    end

    user_response
  end
end
