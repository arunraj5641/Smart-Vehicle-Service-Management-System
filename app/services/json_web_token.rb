require "jwt"

class JsonWebToken
  def self.encode(payload, exp: 24.hours.from_now)
    JWT.encode(payload.merge(exp: exp.to_i), secret)
  end

  def self.decode(token)
    return if token.blank?

    JWT.decode(token, secret, true, algorithm: "HS256").first.with_indifferent_access
  rescue JWT::DecodeError
    nil
  end

  def self.secret
    Rails.application.secret_key_base
  end
end
