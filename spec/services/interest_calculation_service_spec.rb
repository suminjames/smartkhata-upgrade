require 'rails_helper'

RSpec.describe InterestCalculationService do
  let(:subject) { InterestCalculationService.new(ledger, date, payable_interest_rate, receivable_interest_rate) }
  let(:ledger) { create(:ledger) }
  let(:date) { Date.today }
  let(:payable_interest_rate){ 10 }
  let(:receivable_interest_rate) { 20 }
  
  describe ".call" do
    context "when the amount is positive" do
      let(:particular) { create(:particular, fy_code: 7778, transaction_type: 0, amount: 1000, value_date: Date.today - 15.days) }
      let(:another_particular) { create(:particular, fy_code: 7778, transaction_type: 1, amount: 3000, value_date: Date.today - 10.days) }
 
      before do
        ledger.particulars << [particular, another_particular]
      end

      it "returns the receivable interest amount and rate" do
        allow_any_instance_of(InterestCalculationService).to receive(:interest_attributes).and_return({type: 'cr', value: 20})
        calculated_interest_attributes = subject.call
        expect(calculated_interest_attributes[:amount]).to eq(400.0)
        expect(calculated_interest_attributes[:interest_attributes][:type]).to eq('cr')
        expect(calculated_interest_attributes[:interest_attributes][:value]).to eq(20)
      end
    end
    
    context "when the amount is negative" do
      let(:particular) { create(:particular, fy_code: 7778, transaction_type: 0, amount: 1000, value_date: Date.today - 15.days) }
      let(:another_particular) { create(:particular, fy_code: 7778, transaction_type: 0, amount: 3500, value_date: Date.today - 10.days) }
      let(:third_particular) { create(:particular, fy_code: 7778, transaction_type: 1, amount: 2500, value_date: Date.today - 10.days) }

      before do
        ledger.particulars << [particular, another_particular, third_particular]
      end
      
      it "returns the payable interest amount and rate" do
        allow_any_instance_of(InterestCalculationService).to receive(:interest_attributes).and_return({type: 'dr', value: 10})
        calculated_interest_attributes = subject.call
        expect(calculated_interest_attributes[:amount]).to eq(200.0)
        expect(calculated_interest_attributes[:interest_attributes][:type]).to eq('dr')
        expect(calculated_interest_attributes[:interest_attributes][:value]).to eq(10)
      end
    end
  end
end
