module Auth
  class Login
    def self.call(email:, password:)
      new(email:, password:).call
    end

    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.find_by(email: email.to_s.downcase.strip)
      return unless user&.authenticate(password)

      {
        user: user.as_json(except: [:password_digest]),
        token: JsonWebToken.encode(user_id: user.id)
      }
    end

    private

    attr_reader :email, :password
  end
end
