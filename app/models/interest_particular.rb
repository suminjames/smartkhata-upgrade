class InterestParticular < ActiveRecord::Base
  belongs_to :ledger

  enum interest_type: %i[dr cr]

  def self.calculate_interest(date)
    interest_particulars = ClientAccount.to_a.map do |ca|
      ledger = ca.ledger
      
      # SQL query returns either positive or negative value based on the difference
      particular_amount = InterestCalculator.call(ledger, date)
      
      # NOT SURE what to put here.
      #
      # interest_type =
      #
      # interest_rate =
      #
      # Also the business logic to calculate the interest for single ledger
      # calculated_interest =   
      
      InterestParticular.new(amount: calculated_interest, rate: interest_rate.rate, date: date, interest_type: interest_type, ledger_id: ca.ledger.id )
    end

    InterestParticular.import interest_particulars, batch: 200
  end
end



