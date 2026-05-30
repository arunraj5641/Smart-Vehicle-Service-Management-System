module ServiceRecords
  class UpdateStatus
    VALID_STATUSES = %w[scheduled in_progress completed].freeze

    def self.call(service_record:, status:)
      new(service_record:, status:).call
    end

    def initialize(service_record:, status:)
      @service_record = service_record
      @status = status
    end

    def call
      unless VALID_STATUSES.include?(status)
        service_record.errors.add(:status, "is not included in the list")
        raise ActiveRecord::RecordInvalid, service_record
      end

      service_record.update!(status:)
      service_record
    end

    private

    attr_reader :service_record, :status
  end
end
