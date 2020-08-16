class InterestParticular < ActiveRecord::Base
  belongs_to :ledger

  enum interest_type: %i[dr cr]

  def self.calculate_interest(date)
    interest_particulars = ClientAccount.to_a.map do |ca|
      ledger = ca.ledger
      particular_amount = InterestCalculator.call(ledger, date)
      # interest_type = particular_amount.positive?  ? 'dr' : 'cr'
      # interest_rate = InterestRate.where("date >= start_date AND date <= end_date").where(interest_type: (interest_type == 'dr') ? "payable" : "receivable").first
      # calculated_interest = ( particular_amount.to_f * interest_rate.to_f ) / 100.0
      InterestParticular.new(amount: calculated_interest, rate: interest_rate.rate, date: date, interest_type: interest_type, ledger_id: ca.ledger.id )
    end

    InterestParticular.import interest_particulars, batch: 200
  end
end



