module Api
  module V1
    class ServiceTypesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_service_type, only: [:show, :update]
      before_action :require_service_centre!, only: [:create, :update]

      def create
        service_type = ServiceType.create!(service_type_params)

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
    end
  end
end
