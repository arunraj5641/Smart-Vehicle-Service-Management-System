module Api
  module V1
    class ServiceRecordsController < ApplicationController
      before_action :set_service_record, only: [:update, :status]
      before_action :authenticate_user!
      before_action :set_service_record, only: [:show, :update, :status_update]

      def index
        filters = index_filters
        filters[:user_id] = current_user.id unless ["admin", "service_centre"].include?(current_user.role)

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
        return render_error(
          message: "You can only create service records for your own vehicles",
          status: :forbidden,
          errors: { vehicle_id: ["is not owned by you"] }
        ) unless ["admin", "service_centre"].include?(current_user.role) || vehicle.user_id == current_user.id

        attributes = service_record_params.to_h.symbolize_keys
        attributes[:serviced_by] ||= current_user.id if ["admin", "service_centre"].include?(current_user.role)

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
        ) unless ["admin", "service_centre"].include?(current_user.role) || @service_record.vehicle.user_id == current_user.id

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

        service_record = ServiceRecords::Update.call(
          id: params[:id],
          attributes: service_record_params.to_h.symbolize_keys
        )

        render_success(
          data: service_record,
          message: "Service record updated successfully",
          meta: { permissions: permissions_for(:service_record, service_record) }
        )
      end

      def status_update
        return render_error(
          message: "You are not authorized to update the status of this service record",
          status: :forbidden,
          errors: { role: ["is not permitted"] }
        ) unless ["admin", "service_centre"].include?(current_user.role) || @service_record.vehicle.user_id == current_user.id

        status = params.require(:status)
        service_record = ServiceRecords::StatusUpdate.call(
          id: params[:id],
          status: status
        )

        render_success(
          data: service_record,
          message: "Service record status updated successfully",
          meta: { permissions: permissions_for(:service_record, service_record) }
        )
      end

      def update
        service_record = ServiceRecords::Update.call(
          service_record: @service_record,
          attributes: service_record_params.to_h.symbolize_keys
        )

        render_success(
          data: service_record,
          message: "Service record updated successfully"
        )
      end

      def status
        service_record = ServiceRecords::UpdateStatus.call(
          service_record: @service_record,
          status: status_params[:status]
        )

        render_success(
          data: service_record,
          message: "Service record status updated successfully"
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
          :serviced_by,
          :status
        )
      end

      def status_params
        params.require(:service_record).permit(:status)
      end
    end
  end
end
