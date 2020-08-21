class ParticularNetCalculator
  include ApplicationHelper
  
  def initialize(ledger, date = Date.today)
    @ledger = ledger
    @date = date
  end

  def call
    beginning_fy_date = fiscal_year_first_day(get_fy_code(@date))
    ending_fy_date = fiscal_year_last_day(get_fy_code(@date))
    query =
      <<-SQL
        SELECT SUM(CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END)
        FROM particulars
        WHERE (ledger_id = #{@ledger.id}) AND (value_date BETWEEN '#{beginning_fy_date}' AND '#{ending_fy_date}');
      SQL
    ActiveRecord::Base.connection.exec_query(query).first.values.first
  end
end
