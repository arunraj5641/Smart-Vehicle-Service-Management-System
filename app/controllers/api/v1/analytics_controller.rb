module Api
  module V1
    class AnalyticsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user

      def vehicle_costs
        return render_error(
          message: "You are not authorized to view this analytics data",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        ) unless current_user.role == "admin" || current_user.id == @user.id

        data = Analytics::VehicleCosts.call(user_id: @user.id)

        render_success(
          data: data,
          meta: { permissions: permissions_for(:user, @user) }
        )
      end

      def monthly_costs
        return render_error(
          message: "You are not authorized to view this analytics data",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        ) unless current_user.role == "admin" || current_user.id == @user.id

        data = Analytics::MonthlyCosts.call(user_id: @user.id)

        render_success(
          data: data,
          meta: { permissions: permissions_for(:user, @user) }
        )
      end

      private

      def set_user
        user_id = params[:user_id].presence || current_user&.id
        return render_error(message: "user_id is required", status: :unprocessable_entity) if user_id.blank?

        @user = User.find(Integer(user_id.to_s, 10))
      rescue ArgumentError
        render_error(message: "user_id must be a valid integer", status: :unprocessable_entity)
      end
    end
  end
end
