class InterestParticular < ActiveRecord::Base
  belongs_to :ledger

  enum interest_type: %i[dr cr]

  scope :between_record_range, -> (current_date, start_fy_date, end_fy_date) {
    where "('#{current_date}' BETWEEN #{start_fy_date} AND #{end_fy_date})"
  }

  def ledger_id
    ledger.id
  end

  def self.calculate_interest(date)
    beginning_fy_date = fiscal_year_first_day(get_fy_code(date))
    ending_fy_date = fiscal_year_last_day(get_fy_code(date))

    interest_particulars = ClientAccount.to_a.map do |ca|
      ledger = ca.ledger

      particular_amount = InterestCalculator.call(ledger, date)
      interest_type = particular_amount.positive? ? 'cr' : 'dr'
      interest_condition = particular_amount.positive? ? 'receivable' : 'payable'
      applicable_interest_rate = InterestRate.between_record_range(date, beginning_fy_date, ending_fy_date).where(interest_type: interest_condition).first

      calculated_interest = ( particular_amount.abs.to_f * interest_rate.to_f) / 100.0

      InterestParticular.new(amount: calculated_interest, rate: applicable_interest_rate.rate, date: date, interest_type: interest_type, ledger_id: ca.ledger_id )
    end

    InterestParticular.import interest_particulars, batch: 200
  end
end



