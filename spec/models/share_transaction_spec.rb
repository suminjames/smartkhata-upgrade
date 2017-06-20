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
  		subject{create(:share_transaction, isin_info_id:isin_info.id, client_account_id: client_account.id, closeout_amount: 0, transaction_type: 0)}
  		it "returns available balancing transaction" do
  			expect(subject.available_balancing_transactions).to eq("")
  		end
  	end
end