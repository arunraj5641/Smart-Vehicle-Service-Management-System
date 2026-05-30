module ServiceRecords
  class Index
    def self.call(filters:)
      new(filters:).call
    end

    def initialize(filters:)
      @filters = filters
    end

    def call
      scope = ServiceRecord
              .includes(:vehicle, :service_type, :serviced_by_user)
              .order(service_date: :desc, id: :desc)

      scope = scope.where(vehicle_id: filters[:vehicle_id]) if filters[:vehicle_id].present?
      scope = scope.where(service_type_id: filters[:service_type_id]) if filters[:service_type_id].present?
      scope = scope.where(status: filters[:status]) if filters[:status].present?
      scope = scope.where(serviced_by: filters[:serviced_by]) if filters[:serviced_by].present?
      scope = scope.joins(:vehicle).where(vehicles: { user_id: filters[:user_id] }) if filters[:user_id].present?
      scope = scope.joins(:service_type).where(service_types: { service_centre_id: filters[:service_centre_id] }) if filters[:service_centre_id].present?

      scope
    end

    private

    attr_reader :filters
  end
end
