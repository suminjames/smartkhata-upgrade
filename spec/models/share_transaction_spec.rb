require 'rails_helper'

RSpec.describe ShareTransaction, type: :model do
	subject{build(:share_transaction)}
  	include_context 'session_setup'
 
  	describe "validations" do
  		it {should validate_numericality_of(:base_price)}
  	end

  	describe ".as_json" do
  		let!(:isin_info){create(:isin_info)}
  		let!(:client_account){create(:client_account)}
  		subject{create(:share_transaction, isin_info_id:isin_info.id, client_account_id: client_account.id)}
  		it "adds method to json response" do
  			 expect(subject.as_json.keys).to include :isin_info, :client_account
  			expect(subject.as_json[:isin_info]).to eq(isin_info)
  			expect(subject.as_json[:client_account]).to eq(client_account.as_json)
  		end
  	end

  	describe ".available_balancing_transactions" do
  		let!(:isin_info){create(:isin_info)}
  		let!(:client_account){create(:client_account)}
  		subject{create(:share_transaction, isin_info_id:isin_info.id, client_account_id: client_account.id, transaction_type: 0)}
  		it "returns available balancing transaction" do
  			create(:share_transaction, isin_info_id:isin_info.id, client_account_id: client_account.id, transaction_type: 0, date: "2016-12-28")
  			expect(subject.available_balancing_transactions.count).to eq(1)
  		end
  	end

  	describe "#quantity_flows_for_isin" do
  		let!(:isin_info){create(:isin_info)}
  		subject{create(:share_transaction, transaction_type:0, quantity: 100, share_amount: 1000, isin_info_id: isin_info.id)}
  		context "when transaction type is bying" do
  			it "returns array with share quantity flows"
          # subject
  				# expect(ShareTransaction.quantity_flows_for_isin(by_isin_id: isin_info.id,isin_info_id: isin_info.id)).to eq("")
  		end
  	end

    describe "#securities_flows" do
      let!(:isin_info){create(:isin_info)}
      let!(:client_account){create(:client_account, branch_id: 1)}
      subject{create(:share_transaction, isin_info_id:isin_info.id, client_account_id: client_account.id, transaction_type: 0)}
      it "returns array"
    
    end

    describe ".soft_delete" do
      subject{create(:share_transaction)}
      it "returns true" do
        subject.soft_delete
        expect(subject.deleted_at).not_to be_nil
      end
    end

    describe ".soft_undelete" do
      subject{create(:share_transaction)}
      it "returns true" do
        subject.soft_undelete
        expect(subject.deleted_at).to be_nil 
      end
    end

    describe ".update_with_base_price" do
      subject{create(:share_transaction, cgt: 5000, base_price: 2000, quantity: 100, share_rate: 600, net_amount: 10000)}
      it "updates with base price" do
        update = subject.update_with_base_price(:base_price => 500)
        expect(update.update(:base_price => 500)).to be_truthy
        expect(update.calculate_cgt).to eq(5500)
        expect(update).to eq(subject)
      end
    end

    describe ".calculate_cgt" do
      context "when cgt var is less than 0" do
        subject{create(:share_transaction, cgt: 5000, base_price: 2000, quantity: 100, share_rate: 600, net_amount: 10000)}
        it "calculates cgt" do
          expect(subject.calculate_cgt).to eq(5000)
        end
      end

      context "when cgt var isnot less than 0" do
        subject{create(:share_transaction, cgt: 5000, base_price: 200, quantity: 100, share_rate: 600, net_amount: 10000)}
        it "calculates cgt" do
          expect(subject.calculate_cgt).to eq(7000)
        end
      end
    end

    describe ".deal_cancelled" do
      it "returns true" do
        subject.deleted_at = "2017-06-30"
        expect(subject.deal_cancelled).to be_truthy
      end
    end

    describe "#options_for_isin_select" do
      it "returns options for isin select" do
        isin_info1 = create(:isin_info, isin: "Beta")
        isin_info2 = create(:isin_info, isin: "Alpha")
        expect(ShareTransaction.options_for_isin_select).to eq([isin_info2,isin_info1])
      end  
    end

    describe "#options_for_transaction_type_select" do
      it "returns options for transaction type" do
        expect(ShareTransaction.options_for_transaction_type_select).to eq([['Buying', 'buying'],['Selling', 'selling']])
      end
    end

    describe ".closeout_settled?" do
      it "returns true" do
        subject.closeout_settled = true
        expect(subject.closeout_settled?).to be_truthy
      end 
    end

    describe ".stock_commission_amount" do
      subject{create(:share_transaction, commission_amount: 500)}
      it "returns stock commission amount" do
        allow_any_instance_of(ShareTransaction).to receive(:nepse_commission_rate).and_return(2.55)
        expect(subject.stock_commission_amount).to eq(1275)
      end
    end

    describe ".counter_broker" do
      context "when transaction type is buying" do
        it "returns broker no." do
          subject.buying!
          expect(subject.counter_broker).to eq(100)
        end
      end

      context "when transaction type is not buying" do
        it "returns broker no." do
          subject.selling!
          expect(subject.counter_broker).to eq(99)
        end
      end
    end

    # describe ".calculate_base_price" do
    #   it "returns calculated base price" do
    #   end
    # end
end