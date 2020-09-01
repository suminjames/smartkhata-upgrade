class InterestCalculationService
  include ApplicationHelper
  
  attr_reader :ledger, :date, :payable_interest_rate, :receivable_interest_rate
  
  def initialize(ledger, date, payable_interest_rate = nil, receivable_interest_rate = nil)
    @ledger = ledger
    @date = date
    @payable_interest_rate = payable_interest_rate
    @receivable_interest_rate = receivable_interest_rate
  end
  
  def call
    particular_net_sum = ParticularNetCalculator.new(ledger, date).call
    interest_attributes = interest_attributes(particular_net_sum.to_i)
    calculated_interest = (particular_net_sum.to_f.abs * interest_attributes[:value].to_f) / 100.0
    {amount: calculated_interest, interest_attributes: interest_attributes}
  end

  private
  
  def interest_attributes(amount)
    amount.positive? ? {type: 'cr', value: payable_interest_rate || interest_rate('payable')} :  {type: 'dr', value: receivable_interest_rate || interest_rate('receivable')}
  end

  def interest_rate(type)
    InterestRate.get_rate(date, type)
  end
end
