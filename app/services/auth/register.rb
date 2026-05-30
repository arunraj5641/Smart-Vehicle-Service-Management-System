module Auth
  class Register
    def self.call(attributes:)
      new(attributes:).call
    end

    def initialize(attributes:)
      @attributes = attributes
    end

    def call
      user = User.create!(attributes)

      {
        user: user.as_json(except: [:password_digest]),
        token: JsonWebToken.encode(user_id: user.id)
      }
    end

    private

    attr_reader :attributes
  end
end
