require 'rails_helper'

describe Accounts::Branches::ClientBranchService do
  include_context 'session_setup'

  before do
    @client_account = create(:client_account, name: "John", branch_id: 1)
    @other_client_account = create(:client_account, name: "preeti", branch_id: 1)
    @ledger = @client_account.ledger
    @cash_ledger= Ledger.find_or_create_by(name: "Cash")
    @previous_ledger_balance = create(:ledger_balance, ledger_id: @ledger.id, opening_balance:3000, branch_id: 1, fy_code: 7374)
    @ledger_balance = create(:ledger_balance, ledger_id: @ledger.id, branch_id: 1, fy_code: 7475)
    @ledger_daily = create(:ledger_daily, ledger_id: @ledger.id, branch_id: 1, fy_code: 7475, date: '2017-9-16')
    @other_ledger = @other_client_account.ledger
    @voucher = create(:voucher, branch_id: 1, fy_code: 7475)
    @particular = create(:particular, voucher_id: @voucher.id, transaction_date: '2017-9-16', ledger_id: @ledger.id, branch_id: 1, fy_code: 7475)
    @other_particular = create(:particular, voucher_id: @voucher.id, transaction_date: '2017-10-16', ledger_id: @other_ledger.id, branch_id: 1, fy_code: 7475, name: 'test')
    @bill = create(:bill, client_account_id: @client_account.id, date: '2017-9-16', branch_id: 1, fy_code: 7475)
    @settlement = create(:settlement, client_account_id: @client_account.id, date: '2017-9-16', branch_id: 1, fy_code: 7475)
    subject {Accounts::Branches::ClientBranchService.new}
  end
  describe 'move transactions' do
    context "when dry run false" do
      context "when voucher does not have other client particulars" do
        it 'should move all particulars of the voucher' do
          UserSession.selected_fy_code = 7475
          @other_particular.update_attributes(ledger_id: @cash_ledger.id)
          subject.move_transactions(@client_account, 2, nil, false)
          expect(Bill.unscoped.where(client_account_id: @client_account.id).first.branch_id).to eq(2)
          expect(Settlement.where(client_account_id: @client_account.id).first.branch_id).to eq(2)
          expect(@client_account.ledger.particulars.first.branch_id).to eq(2)
          expect(@client_account.ledger.particulars.first.voucher.branch_id).to eq(2)
          expect(@other_particular.reload.branch_id).to eq(2)
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
    context "when dry run true" do
      it "should return nil" do
        UserSession.selected_fy_code = 7475
        expect(subject.move_transactions(@client_account, 2, nil, true)).to eq([nil, nil])
      end
    end
  end

  describe 'patch client branch' do
    context "when dry run false" do
      context "and fy_code length is 1" do
        it 'should patch clients branch' do
          allow(subject).to receive(:move_transactions).with(@client_account, 2, nil, false).and_return([[@ledger.id], [7475]])
          Branch.all.each do |branch|
            allow_any_instance_of(Accounts::Ledgers::PopulateLedgerDailiesService).to receive(:patch_ledger_dailies).with(@ledger, false, branch.id, 7475).and_return(true)
            allow_any_instance_of(Accounts::Ledgers::ClosingBalanceService).to receive(:patch_closing_balance).with(@ledger, all_fiscal_years: false, branch_id: branch.id, fy_code: 7475).and_return(true)
          end

          expect(subject.patch_client_branch(@client_account, 2)).to eq(nil)
        end
      end

      context "and fy_code length is greater than 1" do
        it "should patch opening balance" do
          allow(subject).to receive(:move_transactions).with(@client_account, 2, '2073-08-02', false).and_return([[@ledger.id], [7374, 7475, 7576, 7677, 7778, 7879, 7980]])
          Branch.all.each do |branch|
            allow_any_instance_of(Accounts::Ledgers::PopulateLedgerDailiesService).to receive(:patch_ledger_dailies).with(@ledger, false, branch.id, 7374).and_return(true)
            allow_any_instance_of(Accounts::Ledgers::ClosingBalanceService).to receive(:patch_closing_balance).with(@ledger, all_fiscal_years: false, branch_id: branch.id, fy_code: 7374).and_return(true)
          end
          allow_any_instance_of(Accounts::Ledgers::PullOpeningBalanceService).to receive(:process).and_return(true);

          object = { fy_code: 7475, ledger_ids: [@ledger.id] }
          so = Accounts::Ledgers::PullOpeningBalanceService.new(object)
          expect(Accounts::Ledgers::PullOpeningBalanceService).to receive(:new).with(object).and_return(so)

          expect(subject.patch_client_branch(@client_account, 2,'2073-08-02')).to eq(true)
        end
      end
    end
  end
end