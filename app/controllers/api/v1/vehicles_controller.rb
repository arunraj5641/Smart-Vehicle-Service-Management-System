module Api
  module V1
    class VehiclesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_vehicle, only: [:show, :update]

      def create
        resolved_user_id = current_user.id
        resolved_user_id = vehicle_params[:user_id] || current_user.id if current_user.role == "admin"

        vehicle = Vehicle.create!(vehicle_params.merge(user_id: resolved_user_id))

        render_success(
          data: vehicle,
          message: "Vehicle created successfully",
          meta: { permissions: permissions_for(:vehicle, vehicle) },
          status: :created
        )
      end

      def index
        vehicles = Vehicle.where(user_id: current_user.id)
        vehicles = Vehicle.all if ["admin", "service_centre"].include?(current_user.role)

        vehicles, meta = paginate(vehicles)
        meta[:permissions] = permissions_for(:vehicle)

        render_success(
          data: vehicles,
          meta: meta
        )
      end

      def show
        return render_error(
          message: "You are not authorized to view this vehicle",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        ) unless ["admin", "service_centre"].include?(current_user.role) || @vehicle.user_id == current_user.id

        render_success(
          data: @vehicle,
          meta: { permissions: permissions_for(:vehicle, @vehicle) }
        )
      end

      def update
        return render_error(
          message: "You are not authorized to update this vehicle",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        ) unless ["admin", "service_centre"].include?(current_user.role) || @vehicle.user_id == current_user.id

        @vehicle.update!(vehicle_params)

        render_success(
          data: @vehicle,
          message: "Vehicle updated successfully",
          meta: { permissions: permissions_for(:vehicle, @vehicle) }
        )
      end

      private

      def set_vehicle
        @vehicle = Vehicle.find(params[:id])
      end

      def vehicle_params
        params.require(:vehicle).permit(
          :name,
          :model,
          :number_plate,
          :user_id
        )
      end
    end
  end
end