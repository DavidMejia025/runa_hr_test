class JwtService
  HMAC_SECRET = Rails.application.secrets.secret_key_base

  def self.encode(payload:, exp: 24.hours.from_now)
    payload[:exp] = exp.to_i
puts ".........................................."
puts payload
puts HMAC_SECRET
puts ".........................................."
    JWT.encode(payload, "string")
  end

  def self.decode(token:)
    body = JWT.decode(token, HMAC_SECRET)&.first

    return HashWithIndifferentAccess.new body if body.class == Hash

    body
  rescue JWT::DecodeError => e
    raise ExceptionHandler::InvalidToken, e.message
  end
end
