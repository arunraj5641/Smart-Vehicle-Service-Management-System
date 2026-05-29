module Api
  module V1
    class VehiclesController < ApplicationController

      def create
        vehicle = Vehicle.create!(vehicle_params)

        render_success(
          data: vehicle,
          message: "Vehicle created successfully",
          status: :created
        )
      end

      def index
        vehicles = Vehicle.all
        vehicles, meta = paginate(vehicles)

        render_success(
          data: vehicles,
          meta: meta
        )
      end

      def show
        vehicle = Vehicle.find(params[:id])

        render_success(
          data: vehicle
        )
      end

      private

      def vehicle_params
        params.require(:vehicle).permit(
          :name,
          :number_plate,
          :user_id
        )
      end

    end
  end
end