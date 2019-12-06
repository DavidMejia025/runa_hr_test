class JwtService
  HMAC_SECRET = "CAB577FAF0FEC295C212B4F93C823129F5A6CCA774B4182BD34A4C9FB71789C3"

  def self.encode(payload:, exp: 24.hours.from_now)
    payload[:exp] = exp.to_i

    JWT.encode(payload, HMAC_SECRET)
  end

  def self.decode(token:)
    body = JWT.decode(token, HMAC_SECRET)&.first

    return HashWithIndifferentAccess.new body if body.class == Hash

    body
  rescue JWT::DecodeError => e
    raise ExceptionHandler::InvalidToken, e.message
  end
end
