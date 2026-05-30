module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user, only: [:show]
      before_action :require_admin!, only: [:create]

      def create
        user = User.create!(user_params)

        render_success(
          data: user,
          message: "User created successfully",
          meta: { permissions: permissions_for(:user, user) },
          status: :created
        )
      end

      def show
        return render_error(
          message: "You are not authorized to view this profile",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        ) unless current_user.role == "admin" || current_user.id == @user.id

        render_success(
          data: @user,
          meta: { permissions: permissions_for(:user, @user) }
        )
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(
          :name,
          :email,
          :role,
          :password,
          :password_confirmation
        )
      end
    end
  end
end
