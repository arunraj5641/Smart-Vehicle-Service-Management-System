module Api
  module V1
    class ServiceTypesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_service_type, only: [:show, :update, :destroy]
      before_action :require_service_centre!, only: [:create, :update, :destroy]
      before_action :authorize_service_type_owner!, only: [:update, :destroy]

      def create
        return render_error(
          message: "Only service centres can create service types",
          status: :forbidden,
          errors: { role: ["must be service_centre"] }
        ) unless current_user.role == "service_centre"

        service_type = ServiceType.new(service_type_params)
        service_type.service_centre = current_user
        service_type.save!

        render_success(
          data: service_type,
          message: "Service type created successfully",
          meta: { permissions: permissions_for(:service_type, service_type) },
          status: :created
        )
      end

      def index
        service_types = ServiceType.order(:name)
        service_types, meta = paginate(service_types)
        meta[:permissions] = permissions_for(:service_type)

        render_success(
          data: service_types,
          meta: meta
        )
      end

      def show
        render_success(
          data: @service_type,
          meta: { permissions: permissions_for(:service_type, @service_type) }
        )
      end

      def update
        @service_type.update!(service_type_params)

        render_success(
          data: @service_type,
          message: "Service type updated successfully",
          meta: { permissions: permissions_for(:service_type, @service_type) }
        )
      end

      def destroy
        @service_type.destroy!

        render_success(
          data: {},
          message: "Service type deleted successfully",
          meta: { permissions: permissions_for(:service_type) }
        )
      end

      private

      def set_service_type
        @service_type = ServiceType.find(params[:id])
      end

      def service_type_params
        params.require(:service_type).permit(
          :name,
          :recommended_days
        )
      end

      def authorize_service_type_owner!
        return if current_user.role == "admin" || @service_type.service_centre_id == current_user.id

        render_error(
          message: "You are not authorized to manage this service type",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        )
      end
    end
  end
end
