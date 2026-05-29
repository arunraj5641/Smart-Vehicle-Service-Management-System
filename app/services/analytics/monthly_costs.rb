module Analytics
  class MonthlyCosts
    def self.call(user_id)
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM get_monthly_costs(#{user_id})"
      )
    end
  end
end