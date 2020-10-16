require 'rails_helper'

RSpec.describe LedgerDaily, type: :model do
	subject{build(:ledger_daily)}
  	include_context 'session_setup'

  	describe "#sum_of_closing_balance_of_ledger_dailies_for_ledgers" do
  		context "when last day ledger daily present" do
  			let(:ledger){create(:ledger)}
  			subject{create(:ledger_daily, closing_balance: 1000, date: "2017-6-8" ,ledger: ledger, branch_id: 1, fy_code: 7374)}
  			
  			it "should return sum of closing balance" do
  				subject
  				expect(LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(ledger.id,subject.date, 7374, 1)).to eq(1000)
  			end
  		end

  		context "when last day daily ledger not present" do
  			let(:ledger){create(:ledger)}
  			it "should return closing balance 0" do
  				expect(LedgerDaily.sum_of_closing_balance_of_ledger_dailies_for_ledgers(ledger.id,"2017-6-8", 7374, 1)).to eq(0)
  			end
  		end
  	end

  	describe ".process_daily_ledger" do
  		subject{build(:ledger_daily, date: Date.today)}
  		it "should process daily ledger" do
  			subject.send(:process_daily_ledger)
  			expect(subject.date_bs).to eq(subject.ad_to_bs_string_public(subject.date))
  		end
  	end

end