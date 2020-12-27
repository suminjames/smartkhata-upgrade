class InterestJob < ActiveJob::Base
  include FiscalYearModule

  queue_as :default
  def perform(ledger_id, value_date)
    value_date = value_date.to_date
    fy_code = get_fy_code(value_date)
    final_date =  fiscal_year_last_day(fy_code)
    (value_date .. [value_date,final_date].min).each do |date|
      ActiveRecord::Base.transaction do
        InterestParticular.calculate_interest(date: date, ledger_id: ledger_id)
      end
    end
  end
end
