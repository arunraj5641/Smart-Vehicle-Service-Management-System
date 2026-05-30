module Analytics
  class MonthlyCosts
    SQL = "SELECT * FROM get_monthly_costs($1)".freeze

    def self.call(user_id:)
      new(user_id:).call
    end

    def initialize(user_id:)
      @user_id = user_id
    end

    def call
      sql = ActiveRecord::Base.sanitize_sql_array(["SELECT * FROM get_monthly_costs(?)", user_id])
      ActiveRecord::Base.connection.exec_query(sql).to_a
    end

    private

    attr_reader :user_id
  end
end
