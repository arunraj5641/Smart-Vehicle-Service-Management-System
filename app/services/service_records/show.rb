module ServiceRecords
  class Show
    def self.call(id:)
      new(id:).call
    end

    def initialize(id:)
      @id = id
    end

    def call
      ServiceRecord.includes(:vehicle, :service_type, :serviced_by_user).find(id)
    end

    private

    attr_reader :id
  end
end
