module ServiceRecords
  class Create
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      ServiceRecord.create!(
        service_date: @params[:service_date],
        cost: @params[:cost],
        description: @params[:description],
        vehicle_id: @params[:vehicle_id],
        service_type_id: @params[:service_type_id]
      )
    end
  end
end