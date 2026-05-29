module Analytics
  class VehicleCosts
    def self.call(user_id)
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM get_vehicle_costs($1)",
         "SQL",
        [[nil, user_id]]
      )
    end
  end
end