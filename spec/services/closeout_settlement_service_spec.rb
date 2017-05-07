require 'rails_helper'

RSpec.describe ShortageSettlementService do
  let(:sales_share_transaction_with_closeout) {create(:sales_share_transaction_processed_with_closeout, bill: create(:sales_bill, net_amount: 115130.6726))}
  # let(:nepse_ledger){ Ledger.find_or_create_by!(name: "Nepse Sales")}
  before do
    UserSession.user = create(:user)
    UserSession.selected_branch_id = 1
    UserSession.selected_fy_code = 7374
    Ledger.find_or_create_by!(name: "Close Out")
  end

  # TODO(SUBAS) Make the test more realistic
  # consider making the entry to the ledgers first

  context "sales closeout" do
    context "partial closeout" do
      it "should settle by client" do
        transaction = sales_share_transaction_with_closeout
        closeout_settlement_service = ShortageSettlementService.new(transaction, 'client')
        closeout_settlement_service.process
        expect(transaction.bill.reload.net_amount).to eq(100106.6726)
        expect(transaction.bill.reload.closeout_charge).to eq(15024)
        expect(transaction.client_account.ledger.closing_balance).to eq(15024)
        expect(transaction.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.closing_balance).to eq(-15024)
      end

      it "should settle by broker appropriately" do
        transaction = sales_share_transaction_with_closeout
        closeout_settlement_service = ShortageSettlementService.new(transaction, 'broker')
        closeout_settlement_service.process
        expect(transaction.bill.reload.net_amount).to eq(115130.6726)
        expect(transaction.bill.reload.closeout_charge).to eq(0)
        expect(transaction.client_account.ledger.closing_balance).to eq(0)
        expect(transaction.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.closing_balance).to eq(0)
      end
    end
  end
end