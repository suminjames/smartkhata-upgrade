require 'rails_helper'

RSpec.describe Settlement, type: :model do
	subject{build(:settlement, date_bs: "2074-03-05")}
  	include_context 'session_setup'

  	describe "validations" do
  		it {should validate_presence_of(:date_bs)}
  		it {should validate_presence_of(:branch_id)}
  		it {should validate_presence_of(:fy_code)}
  	end

  	describe ".add_date_from_date_bs" do
  		it "adds ad date" do
  			subject.add_date_from_date_bs
  			expect(subject.date).to eq("2017/06/19".to_date)
  			
  		end

  		context "when date is present" do
  			it "adds bs date" do
  				subject.date = "2017/06/19"
  				subject.date_bs = nil
  				subject.add_date_from_date_bs
  				expect(subject.date).to eq("2017/06/19".to_date)

  			end
  		end
  	end

  	describe "#options_for_settlement_type_select" do
  		it "should return array" do
  			expect(Settlement.options_for_settlement_type_select).to eq([["Receipt", "receipt"], ["Payment", "payment"]])
  		end
  	end

  	describe "#new_settlement_number" do
  		context "when settlement is nil" do
  			it "should return 1" do
  				expect(Settlement.new_settlement_number(nil,nil,nil)).to eq(1)
  			end	
  		end
  		
  		context "when settlement is present" do
  			subject{create(:settlement, branch_id: 1, settlement_type: 0, date_bs: "2074-03-05", fy_code: 7374)}
  			it "should get new settlement number" do
          expect(Settlement.new_settlement_number("7374",subject.branch_id,subject.settlement_type)).to eq(2)
  			end	
  		end
  	end

  	describe ".assign_settlement_number" do
  		subject{build(:settlement, fy_code: "7374", branch_id:1, settlement_type: 0,date_bs: "2074-03-05")}
  		it "should assign settlement number" do
  			allow(Settlement).to receive(:new_settlement_number).and_return(2)
  			subject.assign_settlement_number
  			expect(subject.settlement_number).to eq(2)
  			expect(subject.cash_amount).to eq(0)
  		end
  	end

  	describe ".belongs_to_batch_payment?" do
  		it "should return true" do
  			subject.belongs_to_batch_payment = true
  			expect(subject.belongs_to_batch_payment).to be_truthy
  		end
  	end
end