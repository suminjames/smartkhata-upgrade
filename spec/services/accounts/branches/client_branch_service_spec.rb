require 'rails_helper'

describe Accounts::Branches::ClientBranchService do
  include_context 'session_setup'

  before do
    @client_account = create(:client_account, name: "John", branch_id: 1)
    @other_client_account = create(:client_account, name: "preeti", branch_id: 1)
    @ledger = create(:ledger, client_account_id: @client_account.id, branch_id: 1)
    @cash_ledger= Ledger.find_or_create_by(name: "Cash")
    @ledger_balance = create(:ledger_balance, ledger_id: @ledger.id, branch_id: 1, fy_code: 7475)
    @ledger_daily = create(:ledger_daily, ledger_id: @ledger.id, branch_id: 1, fy_code: 7475, date: '2017-9-16')
    @other_ledger = create(:ledger, client_account_id: @other_client_account.id, branch_id: 1)
    @voucher = create(:voucher, branch_id: 1, fy_code: 7475)
    @particular = create(:particular, voucher_id: @voucher.id, transaction_date: '2017-9-16', ledger_id: @ledger.id, branch_id: 1)
    @other_particular = create(:particular, voucher_id: @voucher.id, transaction_date: '2017-10-16', ledger_id: @other_ledger.id, branch_id: 1)
    @bill = create(:bill, client_account_id: @client_account.id, date: '2017-9-16', branch_id: 1, fy_code: 7475)
    @settlement = create(:settlement, client_account_id: @client_account.id, date: '2017-9-16', branch_id: 1, fy_code: 7475)
    # @client_account.bills << @bill
    subject {Accounts::Branches::ClientBranchService.new}
  end
  describe 'move transactions' do
    context "when voucher does not have other client particulars" do
      it 'should move all particulars of the voucher' do
        UserSession.selected_fy_code = 7475
        @other_particular.update_attributes(ledger_id: @cash_ledger.id)
        subject.move_transactions(@client_account, 2, nil, false)
        expect(Bill.unscoped.where(client_account_id: @client_account.id).first.branch_id).to eq(2)
        expect(Settlement.where(client_account_id: @client_account.id).first.branch_id).to eq(2)
        expect(@client_account.ledger.particulars.first.branch_id).to eq(2)
        expect(@client_account.ledger.particulars.first.voucher.branch_id).to eq(2)
        expect(@other_particular.branch_id).to eq(2)
      end
    end

    context "when voucher have other client particulars" do
      it 'should move only the mentioned client particulars' do
        UserSession.selected_fy_code = 7475
        subject.move_transactions(@client_account, 2, nil, false)
        expect(Bill.unscoped.where(client_account_id: @client_account.id).first.branch_id).to eq(2)
        expect(Settlement.where(client_account_id: @client_account.id).first.branch_id).to eq(2)
        expect(@client_account.ledger.particulars.first.branch_id).to eq(2)
        expect(@client_account.ledger.particulars.first.voucher.branch_id).to eq(1)
        expect(@other_particular.branch_id).to eq(1)
      end
    end

  end

  describe 'patch client branch' do
    it 'should patch clients branch' do
      # debugger
      allow(subject).to receive(:move_transactions).with(@client_account, 2, nil).and_return([[@ledger.id], [7475]])
      allow_any_instance_of(Accounts::Ledgers::PopulateLedgerDailiesService).to receive(:patch_ledger_dailies).with(@ledger, false, 2, 7475).and_return(true)
      allow_any_instance_of(Accounts::Ledgers::ClosingBalanceService).to receive(:patch_closing_balance).with(@ledger, all_fiscal_years: false, branch_id: 2, fy_code: 7475).and_return(true)
      expect(subject.patch_client_branch(@client_account, 2)).to eq([7475])
    end
  end
end