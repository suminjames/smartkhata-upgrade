require 'rails_helper'

RSpec.describe CreateSmsService do
  let(:subject) { CreateSmsService.new }
  
  let(:user) { create(:user) }
  let(:isin_info) { create(:isin_info, isin: "SHPC") }
  let(:another_isin_info) { create(:isin_info, isin: "EBL") }
  
  let(:client_account_first) { create(:client_account, name: "John", branch_id: 1, creator_id: user.id, updater_id: user.id) }
  let(:client_account_second) { create(:client_account, name: "Ben", branch_id: 1, creator_id: user.id, updater_id: user.id) }
  
  let(:share_transaction_purchase) { create(:share_transaction, client_account_id: client_account_first.id, date: '2020-9-18', branch_id: 1, transaction_type: 0, isin_info_id: isin_info.id, contract_no: 12345678, quantity: 100, share_rate: 200) }
  let(:share_transaction_second_purchase) { create(:share_transaction, client_account_id: client_account_first.id, date: '2020-9-18', branch_id: 1, transaction_type: 0, isin_info_id: another_isin_info.id, contract_no: 12345679, quantity: 50, share_rate: 300) }
  let(:share_transaction_third_purchase){ create(:share_transaction, client_account_id: client_account_first.id, date: '2020-9-18', branch_id: 1, transaction_type: 0, isin_info_id: another_isin_info.id, contract_no: 12345684, quantity: 55, share_rate: 305) }
  let(:share_transaction_sell) { create(:share_transaction, client_account_id: client_account_first.id, date: '2020-9-18', branch_id: 1, transaction_type: 1, isin_info_id: another_isin_info.id, contract_no: 12345680, quantity: 150, share_rate: 500) }

  let(:share_transaction_random) { create(:share_transaction, client_account_id: client_account_second.id, date: '2020-9-18', branch_id: 1, transaction_type: 1, isin_info_id: isin_info.id, contract_no: 12345681, quantity: 200, share_rate: 700) }
  
  describe ".create_by_floorsheet_date" do
    context "when the transaction message for the day are not created" do
      context "and it contains at least one uncancelled share transactions" do
        before do
          [share_transaction_purchase, share_transaction_second_purchase, share_transaction_third_purchase, share_transaction_sell, share_transaction_random]
        end
        
        it "creates transactions messages for all clients accounts for the day" do
          subject.create_by_floorsheet_date

          expect(TransactionMessage.count).to eq(2)
          expect(TransactionMessage.first.sms_message).to include('bought SHPC,100@200;EBL,50@300,55@305;sold EBL,150@500')
          expect(TransactionMessage.second.sms_message).to include('sold SHPC,200@700;')
        end
      end
    end
  end
end
