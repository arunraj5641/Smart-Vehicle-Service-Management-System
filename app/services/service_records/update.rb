module ServiceRecords
  class Update
    def self.call(service_record:, attributes:)
      new(service_record:, attributes:).call
    end

    def initialize(service_record:, attributes:)
      @service_record = service_record
      @attributes = attributes
    end

    def call
      service_record.update!(attributes)
      service_record
    end

    private

    attr_reader :service_record, :attributes
  end
end
