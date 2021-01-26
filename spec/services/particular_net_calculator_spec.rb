require 'rails_helper'

RSpec.describe ParticularNetCalculator  do

  let(:ledger){ create(:ledger) }
  let(:debit_particular){ create(:particular, fy_code: 7778, transaction_type: 0, amount: 1000, value_date: Date.today - 15.days) }
  let(:credit_particular){  create(:particular, fy_code: 7778, transaction_type: 1, amount: 500, value_date: Date.today - 10.days) }

  describe ".call" do
    it "returns the particular net total for a ledger" do
      ledger.particulars << [ debit_particular, credit_particular ]
      particular_calculator = ParticularNetCalculator.new(ledger, Date.today)
      expect(particular_calculator.call).to eq("500.00")
    end
  end
end
