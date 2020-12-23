class ParticularNetCalculator
  include ApplicationHelper

  attr_reader :ledger_id, :date
  def initialize(ledger_id, date = Date.today)
    @ledger_id = ledger_id
    @date = date
  end

  def call
    beginning_fy_date = fiscal_year_first_day(get_fy_code(date))
    query =
      <<-SQL
        SELECT SUM(CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END)
        FROM particulars
        WHERE (ledger_id = #{ledger_id}) AND (value_date BETWEEN '#{beginning_fy_date}' AND '#{date}');
      SQL
    ActiveRecord::Base.connection.exec_query(query).first.values.first
  end
end
