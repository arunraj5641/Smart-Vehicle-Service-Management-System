module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_user!, only: [:logout]

      def register
        attributes = register_params.to_h.symbolize_keys
        return render_error(
          message: "Admin registration is not allowed",
          status: :forbidden,
          errors: { role: ["cannot be admin"] }
        ) if attributes[:role].to_s == "admin"

        result = Auth::Register.call(attributes: attributes)

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

      def logout
        render_success(
          data: {},
          message: "Logout successful"
        )
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
