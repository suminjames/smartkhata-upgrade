class InterestCalculator
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
        SELECT (debit_particular - credit_particular) FROM (SELECT SUM( CASE WHEN transaction_type = 0 Then amount ELSE 0 END ) AS debit_particular,
        SUM( CASE WHEN transaction_type = 1 THEN amount ELSE 0 END ) as credit_particular
        FROM particulars
        WHERE ( ledger_id = #{@ledger.id}) AND ( value_date BETWEEN '#{beginning_fy_date}' AND '#{ending_fy_date}' )) AS particular_total;
      SQL
    ActiveRecord::Base.connection.exec_query(query).first.values.first
  end
end
