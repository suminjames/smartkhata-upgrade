require 'rails_helper'

describe Accounts::Ledgers::PullOpeningBalanceService do
  include_context 'session_setup'



  before do
    @new_branch = create(:branch)
    @fy_code = 7374
    @old_fy_code = 7273

    @ledger = create(:ledger)
    # @ledger_balance_org = create(:ledger_balance_org,fy_code: 7273, ledger_id: @ledger.id)
    # @ledger_balance_1 = create(:ledger_balance, fy_code: 7273, ledger_id: @ledger.id)
    @ledger_balance_2 = create(:ledger_balance, opening_balance: 2000, branch_id: @new_branch.id, fy_code: @old_fy_code, ledger_id: @ledger.id)
    @ledger_balance = create(:ledger_balance, branch_id: @new_branch.id, fy_code: 7374, ledger_id: @ledger.id)



    # considering old fy code
    allow_any_instance_of(Accounts::Ledgers::PullOpeningBalanceService).to receive(:get_fy_code).and_return(7374)
    allow_any_instance_of(Accounts::Ledgers::PopulateLedgerDailiesService).to receive(:get_fy_code).and_return(7374)

    subject {Accounts::Ledgers::PullOpeningBalanceService.new(branch_id: @new_branch.id, fy_code: @fy_code)}

    # @ledger_balance_org.update_attributes(closing_balance: 7000)
    # @ledger_balance_1.update_attributes(closing_balance: 5000)
    # @ledger_balance_2.update_attributes(closing_balance: 2000)
  end

  # describe '.process' do
  #   it "pulls opening balance for the ledgers of client accounts in branch" do
  #     subject.process
  #     UserSession.selected_branch_id = @new_branch.id
  #     expect(LedgerBalance.unscoped.where(ledger_id: @ledger.id).count).to eq(6)
  #     expect(@ledger.closing_balance).to eq(2000)
  #
  #     UserSession.selected_branch_id = 0
  #     expect(@ledger.closing_balance).to eq(7000)
  #   end
  # end

  describe '.process' do
    it "pulls opening balance for the ledgers of client accounts in branch" do
      subject.process
      expect(@ledger.reload.opening_balance(@old_fy_code, @new_branch.id)).to eq(2000)
      branch_ids = Branch.all.pluck(:id)
      branch_ids.each do |branch_id|
        allow_any_instance_of(Accounts::Ledgers::PopulateLedgerDailiesService).to receive(:process).with([@ledger.id], false, branch_id).and_return(true)
        allow_any_instance_of(Accounts::Ledgers::ClosingBalanceService).to receive(:process).with([@ledger.id], false, branch_id).and_return(true)
      end
      expect(subject.process).to eq(nil)
    end
  end
end
