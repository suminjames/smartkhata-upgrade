# == Schema Information
#
# Table name: interest_particulars
#
#  id            :integer          not null, primary key
#  amount        :float
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

  def self.calculate_interest(date = Date.today, payable_interest_rate = nil, receivable_interest_rate = nil)
    interest_particulars = []

    Ledger.with_particulars_from_client_ledger(date).find_each do |ledger|
      interest_calculable_data = InterestCalculationService.new(ledger, date, payable_interest_rate, receivable_interest_rate).call
      interest_particulars << InterestParticular.new(amount: interest_calculable_data[:amount], rate: interest_calculable_data[:interest_attributes][:value], date: date, interest_type: interest_calculable_data[:interest_attributes][:type], ledger_id: ledger.id)
    end

    InterestParticular.import interest_particulars, batch_size: 1000
  end
end
