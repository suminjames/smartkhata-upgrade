require 'rails_helper'

RSpec.describe CreateSmsService do
  let(:date) { '2020-9-18' }
  let(:subject) { CreateSmsService.new(transaction_date: date, broker_code: 11) }

  let(:user) { create(:user) }
  let(:isin_info) { create(:isin_info, isin: "SHPC") }
  let(:another_isin_info) { create(:isin_info, isin: "EBL") }
  let (:branch) { create(:branch) }

  let(:client_account_first) { create(:client_account, name: "John", branch_id: branch.id, creator_id: user.id, updater_id: user.id) }
  let(:client_account_second) { create(:client_account, name: "Ben", branch_id: branch.id, creator_id: user.id, updater_id: user.id) }

  let(:share_transaction_purchase) { create(:share_transaction, client_account_id: client_account_first.id, date: date, branch_id: branch.id, transaction_type: 0, isin_info_id: isin_info.id, contract_no: 12345678, quantity: 100, share_rate: 200) }
  let(:share_transaction_second_purchase) { create(:share_transaction, client_account_id: client_account_first.id, date: date, branch_id: branch.id, transaction_type: 0, isin_info_id: another_isin_info.id, contract_no: 12345679, quantity: 50, share_rate: 300) }
  let(:share_transaction_third_purchase){ create(:share_transaction, client_account_id: client_account_first.id, date: date, branch_id: branch.id, transaction_type: 0, isin_info_id: another_isin_info.id, contract_no: 12345684, quantity: 55, share_rate: 305) }
  let(:share_transaction_sell) { create(:share_transaction, client_account_id: client_account_first.id, date: date, branch_id: branch.id, transaction_type: 1, isin_info_id: another_isin_info.id, contract_no: 12345680, quantity: 150, share_rate: 500) }

  let(:share_transaction_random) { create(:share_transaction, client_account_id: client_account_second.id, date: date, branch_id: branch.id, transaction_type: 1, isin_info_id: isin_info.id, contract_no: 12345681, quantity: 200, share_rate: 700) }

  describe ".create_by_floorsheet_date" do
    context "when the transaction message for the day are not created" do
      context "and it contains at least one uncancelled share transactions" do
        before do
          [share_transaction_purchase, share_transaction_second_purchase, share_transaction_third_purchase, share_transaction_sell, share_transaction_random]
        end

        it "creates transactions messages for all clients accounts for the day" do
          subject.create_by_floorsheet_date

          expect(TransactionMessage.count).to eq(2)
          expect(TransactionMessage.first.sms_message).to eq('John bought SHPC,100@200;EBL,105@302.62;sold EBL,150@500;On 06/02 Bill No7374-1 .Pay Rs 349467.81.Please do WACC and EDIS after sales.BNo 11')
          expect(TransactionMessage.first.share_transactions.to_a).to eq([share_transaction_purchase, share_transaction_second_purchase, share_transaction_third_purchase, share_transaction_sell])
          expect(TransactionMessage.second.sms_message).to eq('Ben, sold SHPC,200@700;On 06/02.Please do WACC and EDIS after sales.BNo 11')
          expect(TransactionMessage.last.share_transactions.to_a).to eq([share_transaction_random])
        end
      end
    end
  end

  describe ".change_message" do
    before do
      [share_transaction_purchase, share_transaction_second_purchase, share_transaction_third_purchase, share_transaction_sell, share_transaction_random]
      subject.create_by_floorsheet_date
    end

    context "when only one share transaction" do
      it "soft deletes the message once the transaction is cancelled" do
        share_transaction_random.update(quantity: 0)
        transaction_message = TransactionMessage.last
        CreateSmsService.new(transaction_date: date, broker_code: 11, transaction_message: transaction_message).change_message
        expect(transaction_message.reload.deleted_at).to_not be nil
      end
    end
    context "when more than one share transaction for same client" do
      it "updates the message once the transaction is cancelled" do
        share_transaction_third_purchase.update(quantity: 0)
        transaction_message = TransactionMessage.first
        CreateSmsService.new(transaction_date: date, broker_code: 11, transaction_message: transaction_message).change_message
        expect(transaction_message.reload.sms_message).to eq('John bought SHPC,100@200;EBL,50@300;sold EBL,150@500;On 06/02 Bill No7374-11 .Pay Rs 232978.54.Please do WACC and EDIS after sales.BNo 11')
      end
    end
  end
end
