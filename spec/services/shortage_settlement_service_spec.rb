require 'rails_helper'

RSpec.describe ShortageSettlementService do

  include FiscalYearModule

  let(:current_user) {create(:user)}
  let(:branch){create(:branch)}
  let(:client_account) {create(:client_account, current_user_id: current_user.id)}
  let(:sales_share_transaction_with_closeout) {create(:sales_share_transaction_processed_with_closeout, client_account: client_account, contract_no: "201611284117937", bill: create(:sales_bill, net_amount: 115130.6726))}
  let(:purchase_share_transaction_with_closeout) {create(:buy_transaction_processed_with_closeout,client_account: client_account, contract_no: "201611284117938", bill: create(:purchase_bill, net_amount: 116489.27 ))}
  # let(:nepse_ledger){ Ledger.find_or_create_by!(name: "Nepse Sales")}
  let(:current_tenant) { Tenant.new(name: 'test', full_name: 'tenant test') }
  let(:balancing_transaction) { create(:balancing_transaction, client_account: client_account, isin_info: purchase_share_transaction_with_closeout.isin_info , bill: create(:purchase_bill, net_amount: 12818.351))}

  before do
    @fy_code = get_fy_code
    Ledger.find_or_create_by!(name: "Close Out")
    allow_any_instance_of(FilesImportServices::ImportCm31).to receive(:open_file).and_return(nil)
  end

  # TODO(SUBAS) Make the test more realistic
  # consider making the entry to the ledgers first

  context "sales closeout" do
    context "partial closeout" do
      it "should settle by client" do
        transaction = sales_share_transaction_with_closeout
        closeout_settlement_service = ShortageSettlementService.new(transaction, 'client', current_tenant, current_user: current_user, branch: branch)
        closeout_settlement_service.process
        expect(transaction.bill.reload.net_amount.to_f).to eq(100106.67)
        expect(transaction.bill.reload.closeout_charge).to eq(15024)
        expect(transaction.client_account.ledger.closing_balance(@fy_code)).to eq(15024)
        expect(transaction.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.closing_balance(@fy_code)).to eq(-15024)
      end

      it "should settle by broker appropriately" do
        transaction = sales_share_transaction_with_closeout
        closeout_settlement_service = ShortageSettlementService.new(transaction, 'broker', current_tenant, current_user: current_user, branch: branch)
        closeout_settlement_service.process
        expect(transaction.bill.reload.net_amount.to_f).to eq(115130.67)
        expect(transaction.bill.reload.closeout_charge).to eq(0)
        expect(transaction.client_account.ledger.closing_balance(@fy_code)).to eq(0)
        expect(transaction.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.closing_balance(@fy_code)).to eq(0)
      end
    end

    context "buy closeout" do
      it "should settle by counter broker appropriately" do
        transaction = purchase_share_transaction_with_closeout
        broker_ledger = create(:ledger, name: 'Broker 59')

        closeout_settlement_service = ShortageSettlementService.new(transaction, 'counter_broker', current_tenant, balancing_transaction_ids: [balancing_transaction.id],current_user: current_user, branch: branch)

        allow(closeout_settlement_service).to receive(:receipt_bank_account_ledger).and_return(create(:bank_account).ledger)
        allow(closeout_settlement_service).to receive(:counter_broker_ledger).and_return(broker_ledger)
        allow(closeout_settlement_service).to receive(:get_client_reversal_amount).and_return(12818.351)

        closeout_settlement_service.process

        expect(closeout_settlement_service.error).to be_nil
        # no change on bill amount
        expect(transaction.bill.reload.net_amount.to_f).to eq(116489.27)
        expect(transaction.bill.reload.closeout_charge).to eq(0)

        # since we have not made the entry to the client the amount will be credited to client
        # it should have debited exact amount making it zero
        expect(transaction.client_account.ledger.closing_balance(@fy_code).to_f).to eq(-12818.35)
        expect(transaction.client_account.ledger.particulars.last.hide_for_client).to be_truthy

        expect(transaction.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.closing_balance(@fy_code)).to eq(0)
        expect(broker_ledger.closing_balance(@fy_code).to_f).to eq(-2205.65)
      end

      it "should settle by broker appropriately" do
        transaction = purchase_share_transaction_with_closeout
        broker_ledger = create(:ledger, name: 'Broker 59')

        closeout_settlement_service = ShortageSettlementService.new(transaction, 'broker', current_tenant, balancing_transaction_ids: [balancing_transaction.id], current_user: current_user, branch: branch)

        allow(closeout_settlement_service).to receive(:receipt_bank_account_ledger).and_return(create(:bank_account).ledger)
        allow(closeout_settlement_service).to receive(:counter_broker_ledger).and_return(broker_ledger)
        allow(closeout_settlement_service).to receive(:get_client_reversal_amount).and_return(12818.351)

        closeout_settlement_service.process
        expect(closeout_settlement_service.error).to be_nil
        # no change on bill amount
        expect(transaction.bill.reload.net_amount).to eq(116489.27 )
        expect(transaction.bill.reload.closeout_charge).to eq(0)

        # since we have not made the entry to the client the amount will be credited to client
        # it should have debited exact amount making it zero

        expect(transaction.client_account.ledger.closing_balance(@fy_code).to_f).to eq(-12818.35)
        expect(transaction.client_account.ledger.particulars.last.hide_for_client).to be_truthy

        expect(transaction.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.closing_balance(@fy_code).to_f).to eq(-2205.65)
      end
    end
  end
end
