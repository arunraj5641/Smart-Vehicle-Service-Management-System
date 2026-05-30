module Api
  module V1
    class ServiceRecordsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_service_record, only: [:show, :update, :status_update]
      before_action :require_service_centre!, only: [:create, :update, :status_update]
      before_action :authorize_service_record_owner!, only: [:update, :status_update]

      def index
        filters = index_filters
        filters[:user_id] = current_user.id if current_user.role == "user"
        filters[:service_centre_id] = current_user.id if current_user.role == "service_centre"

        service_records = ServiceRecords::Index.call(filters: filters)
        service_records, meta = paginate(service_records)
        meta[:permissions] = permissions_for(:service_record)
        meta[:filters] = { applied_filters: index_filters }

        render_success(
          data: service_records,
          meta: meta
        )
      end

      def create
        vehicle = Vehicle.find(service_record_params[:vehicle_id])
        service_type = ServiceType.find(service_record_params[:service_type_id])
        return unless authorize_service_type!(service_type)

        attributes = service_record_params.to_h.symbolize_keys
        attributes[:serviced_by] = current_user.id if current_user.role == "service_centre"
        attributes[:serviced_by] ||= current_user.id if current_user.role == "admin"

        service_record = ServiceRecords::Create.call(attributes: attributes)

        render_success(
          data: service_record,
          message: "Service record created successfully",
          meta: { permissions: permissions_for(:service_record, service_record) },
          status: :created
        )
      end

      def show
        return render_error(
          message: "You are not authorized to view this service record",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        ) unless can_view_service_record?(@service_record)

        render_success(
          data: @service_record,
          meta: { permissions: permissions_for(:service_record, @service_record) }
        )
      end

      def update
        return render_error(
          message: "You are not authorized to update this service record",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        ) unless ["admin", "service_centre"].include?(current_user.role) || @service_record.vehicle.user_id == current_user.id

        attributes = service_record_params.to_h.symbolize_keys
        return if attributes[:service_type_id].present? && !authorize_service_type!(ServiceType.find(attributes[:service_type_id]))
        attributes[:serviced_by] = current_user.id if current_user.role == "service_centre"

        service_record = ServiceRecords::Update.call(
          service_record: @service_record,
          attributes: attributes
        )

        render_success(
          data: service_record,
          message: "Service record updated successfully",
          meta: { permissions: permissions_for(:service_record, service_record) }
        )
      end

      def status_update
        status = requested_status
        return render_error(
          message: "Missing required parameter",
          status: :bad_request,
          errors: { status: ["is required"] }
        ) if status.blank?

        service_record = ServiceRecords::UpdateStatus.call(
          service_record: @service_record,
          status: status
        )

        render_success(
          data: service_record,
          message: "Service record status updated successfully",
          meta: { permissions: permissions_for(:service_record, service_record) }
        )
      end

      private

      def set_service_record
        @service_record = ServiceRecords::Show.call(id: params[:id])
      end

      def index_filters
        params.permit(:vehicle_id, :service_type_id, :status, :serviced_by, :user_id)
              .to_h
              .symbolize_keys
      end

      def service_record_params
        params.require(:service_record).permit(
          :service_date,
          :description,
          :cost,
          :next_service_date,
          :vehicle_id,
          :service_type_id,
          :status
        )
      end

      def requested_status
        params[:status].presence || params.dig(:service_record, :status).presence
      end

      def authorize_service_record_owner!
        return if current_user.role == "admin"
        return if @service_record.service_type.service_centre_id == current_user.id

        render_error(
          message: "You are not authorized to update this service record",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        )
      end

      def authorize_service_type!(service_type)
        return true if current_user.role == "admin" || service_type.service_centre_id == current_user.id

        render_error(
          message: "Service type does not belong to this service centre",
          status: :unprocessable_entity,
          errors: { service_type_id: ["does not belong to this service centre"] }
        )
        false
      end

      def can_view_service_record?(service_record)
        return true if current_user.role == "admin"
        return true if current_user.role == "service_centre" && service_record.service_type.service_centre_id == current_user.id

        service_record.vehicle.user_id == current_user.id
      end
    end
  end
end
