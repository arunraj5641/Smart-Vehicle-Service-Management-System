module Api
  module V1
    class AuthController < ApplicationController
      def register
        result = Auth::Register.call(attributes: register_params.to_h.symbolize_keys)

        render_success(
          data: result,
          message: "User registered successfully",
          status: :created
        )
      end

      def login
        result = Auth::Login.call(
          email: login_params[:email],
          password: login_params[:password]
        )

        return render_error(message: "Invalid email or password", status: :unauthorized) unless result

        render_success(data: result, message: "Login successful")
      end

      private

      def register_params
        params.require(:user).permit(:name, :email, :password, :role)
      end

      def login_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
