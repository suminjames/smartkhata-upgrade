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

  def self.calculate_interest(date: Date.yesterday, ledger_id: nil, payable_interest_rate: nil, receivable_interest_rate: nil)
    interest_particulars = []

    fy_code = get_fy_code(date)

    if ledger_id.present?
      ledgers = Ledger.where(id: [ledger_id]).select(:id)
    else
      ledgers = Ledger
        .find_all_client_ledgers
        .where( id: Particular.where(value_date: date).distinct(:ledger_id).select(:ledger_id)).select(:id)
    end

    ledgers.find_each do |ledger|
      ledger_id = ledger.id
      interest_calculable_data = InterestCalculationService.new(ledger_id, date, payable_interest_rate, receivable_interest_rate).call
      if interest_calculable_data
        interest_particulars << InterestParticular.new(amount: interest_calculable_data[:amount], rate: interest_calculable_data[:interest_attributes][:value], date: date, interest_type: interest_calculable_data[:interest_attributes][:type], ledger_id: ledger_id)
      end
    end

    InterestParticular.import(interest_particulars, batch_size: 1000, on_duplicate_key_update: {conflict_target: [:ledger_id, :date], columns: [:amount, :rate, :interest_type]}) if interest_particulars.present?
  end
end
