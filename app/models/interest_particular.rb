# == Schema Information
#
# Table name: interest_particulars
#
#  id            :integer          not null, primary key
#  amount        :string
#  rate          :integer
#  date          :date
#  interest_type :integer
#  ledger_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class InterestParticular < ActiveRecord::Base
  extend FiscalYearModule

  belongs_to :ledger

  enum interest_type: %i[dr cr]

  def self.calculate_interest(date)
    fy_first_day = fiscal_year_first_day(get_fy_code(date))
    fy_last_day = fiscal_year_last_day(get_fy_code(date))

    interest_particulars = ClientAccount.all.to_a.map do |ca|
      ledger = ca.ledger

      next if ledger.particulars.size == 0

      particular_net_sum = InterestCalculator.new(ledger, date).call
      interest_type = particular_net_sum.to_f.positive? ? 'cr' : 'dr'
      interest_condition = particular_net_sum.to_f.positive? ? 'receivable' : 'payable'

      applicable_interest_rate = InterestRate.between_record_range(date, fy_first_day, fy_last_day).where(interest_type: interest_condition).first

      calculated_interest_amount = (particular_net_sum.abs.to_f * applicable_interest_rate.to_f) / 100.0

      ledger.interest_particulars.new(amount: calculated_interest_amount, rate: applicable_interest_rate.rate, date: date, interest_type: interest_type)
    end

    InterestParticular.import interest_particulars, batch: 200
  end
end
