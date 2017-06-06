require 'rails_helper'

RSpec.describe LedgerBalance, type: :model do
	subject{build(:ledger_balance)}
  	include_context 'session_setup'

  	describe "validations" do
  		it { should validate_uniqueness_of(:branch_id).scoped_to([:fy_code, :ledger_id] )}
  	end

  	describe ".update_opening_closing_balance" do
  		context "when opening balance is not blank" do
  			it "should return opening balance" do
  				subject.cr!
  				subject.opening_balance = 1000
  				expect(subject.update_opening_closing_balance).to eq(-1000)
  			end
  		end

  		context "when ledger balance is a new record " do
  			it "closing balance should be equal to opening balance" do
  				subject.opening_balance = 500
  				expect(subject.update_opening_closing_balance).to eq(500)
  			end
  		end

  		context "when opening balance is changed" do
  			it "should change closing balance" do
  				subject.opening_balance = 5000
  				subject.closing_balance = 1000
  				expect(subject.update_opening_closing_balance).to eq(6000)
  			end
  		end

  		context "when opening balance is blank" do
  			it "should return zero" do
  				expect(subject.update_opening_closing_balance).to eq(0)
  			end
  		end
  	end
end