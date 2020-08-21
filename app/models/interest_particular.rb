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

    interest_particulars = []

    ClientAccount.all.to_a.map do |ca|
      ledger = ca.ledger
      next if ledger.particulars.size == 0

      particular_net_sum = ParticularNetCalculator.new(ledger, date).call
      interest_type = particular_net_sum.to_f.positive? ? 'cr' : 'dr'
      interest_condition = particular_net_sum.to_f.positive? ? 'receivable' : 'payable'

      date_range_sql = ":end_date >= '#{date}' and '#{date}' >= :start_date"
      applicable_interest_rate = InterestRate.where(date_range_sql, start_date: fy_first_day, end_date: fy_last_day).where(interest_type: interest_condition).first
      calculated_interest_amount = (particular_net_sum.to_f.abs * applicable_interest_rate.rate.to_f) / 100.0

      interest_particulars << InterestParticular.new(amount: calculated_interest_amount, rate: applicable_interest_rate.rate, date: date, interest_type: interest_type, ledger_id: ledger.id)
    end

    InterestParticular.import interest_particulars, batch: 200
    # can be used later for returning ids or results only as well
    end
  end
