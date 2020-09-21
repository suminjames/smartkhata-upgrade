require 'rails_helper'

RSpec.describe SmartkhataMailer, type: :mailer do
  let(:date) { '2020-09-21' }
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user) }
  let(:isin_info) { create(:isin_info, isin: "SHPC") }
  let(:client_account) { create(:client_account, name: "John", branch_id: 1, creator_id: user.id, updater_id: user.id) }
  
  let(:bill) { create(:bill, date: date, creator_id: user.id, updater_id: user.id) }
  let(:share_transaction) { create(:share_transaction, client_account_id: client_account.id, date: date, branch_id: 1, transaction_type: 0, isin_info_id: isin_info.id, contract_no: 12345678, quantity: 100, share_rate: 200, bill_id: bill.id) }
  let(:transaction_message) { create(:transaction_message, client_account_id: client_account.id, bill_id: bill.id, transaction_date: date) }
  let(:mail) { SmartkhataMailer.transaction_message_email(transaction_message.id, tenant.id) }
  
  describe ".transaction_message_email" do
    context "when the transaction message has associated bill" do
      before do
        bill.share_transactions << share_transaction
      end

      it "renders the sender email" do
        expect(mail.from).to eq(["accounts@example.com"])
      end

      it "renders the receiver email" do
        expect(mail.to).to eq([client_account.email])
      end

      it "renders the appropriate subject" do
        expect(mail.subject).to eq("Your transaction message and bill from Danphe")
      end
      
      it "renders the both bill and transaction attachments" do
        attachments = mail.attachments
        expect(attachments.size).to eq(2)
        expect(attachments[0].filename).to eq("TransactionMessage_2020-09-21_4.pdf")
        expect(attachments[1].filename).to eq("Bill_2020-09-21_4.pdf")
      end
    end
    
    context "when the transaction message has no associated bill" do
      let!(:another_transaction_message) { create(:transaction_message, client_account_id: client_account.id, transaction_date: date) }
      let!(:another_mail) { SmartkhataMailer.transaction_message_email(another_transaction_message.id, tenant.id) }

      it "renders the appropriate subject" do
        expect(another_mail.subject).to eq("Your transaction message from Danphe")
      end
      
      it "renders the transactions message attachment only" do
        attachments = another_mail.attachments
        expect(attachments.size).to eq(1)
        expect(attachments[0].filename).to eq("TransactionMessage_2020-09-21_6.pdf")
      end
    end
  end
end
