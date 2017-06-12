require 'rails_helper'

RSpec.describe NepseSettlement, type: :model do
	subject{build(:nepse_settlement)}
  	include_context 'session_setup'

  	describe ".bills_for_payment_letter_list" do
  		# status for bill is pending( by default)
  		let(:bill1){create(:bill, net_amount: 3000)}
  		context "when require processing is true" do
        context "when net amount is greater than 0" do
          it "should return bill" do
            subject{create(:nepse_settlement)}
            subject.bills << bill1
            allow_any_instance_of(Bill).to receive(:requires_processing?).and_return(true)
            expect(subject.bills_for_payment_letter_list).to eq([bill1])
          end
        end
      end
  		context "when require processing is true" do
        context "and net net_amount is less than 0" do
          let(:bill){create(:bill, net_amount: -3000)}
          it "should return empty array" do
            subject{create(:nepse_settlement)}
            subject.bills << bill
            allow_any_instance_of(Bill).to receive(:requires_processing?).and_return(true)
            expect(subject.bills_for_payment_letter_list).to eq([])
          end
        end
  		end

  		context "when require processing is not true" do
  			let(:bill2){create(:bill)}
  			it "should return empty array" do
	  			subject{create(:nepse_settlement)}
	  			subject.bills << bill2
          allow_any_instance_of(Bill).to receive(:requires_processing?).and_return(false)
	  			expect(subject.bills_for_payment_letter_list).to eq([])
  			end
  		end
  	end

  	describe ".bills_for_sales_payment_list" do
  		context "when require processing is true" do
  			context "and net amount is greater than 0" do
  				let(:bill){create(:bill, net_amount: 2000)}
  				it "should return bill for sale payment" do
  					subject{create(:nepse_settlement)}
  					subject.bills << bill
            allow_any_instance_of(Bill).to receive(:requires_processing?).and_return(true)
  					expect(subject.bills_for_sales_payment_list).to eq([bill])
  				end
  			end
  		end

      context "when require processing is true" do
        context "and net amount is less than 0" do
          let(:bill){create(:bill, net_amount: -2000)}
          it "should return empty array" do
            subject{create(:nepse_settlement)}
            subject.bills << bill
            allow_any_instance_of(Bill).to receive(:requires_processing?).and_return(true)
            expect(subject.bills_for_sales_payment_list).to eq([])
          end
        end
      end

      context "when require processing is not true" do
        let(:bill){create(:bill)}
        it "should return empty array" do
          subject{create(:nepse_settlement)}
          subject.bills << bill
          allow_any_instance_of(Bill).to receive(:requires_processing?).and_return(false)
          expect(subject.bills_for_sales_payment_list).to eq([])
        end
      end
  	end

    describe "#settlement_types" do
      it "should return array for settlement types" do
        expect(subject.class.settlement_types).to eq(["NepsePurchaseSettlement","NepseSaleSettlement"])
      end
    end

end