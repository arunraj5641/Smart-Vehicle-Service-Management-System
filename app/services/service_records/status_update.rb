module ServiceRecords
  class StatusUpdate
    def self.call(id:, status:)
      new(id: id, status: status).call
    end

    def initialize(id:, status:)
      @id = id
      @status = status
    end

    def call
      service_record = ServiceRecord.find(id)
      service_record.update!(status: status)
      service_record
    end

    private

    attr_reader :id, :status
  end
end
