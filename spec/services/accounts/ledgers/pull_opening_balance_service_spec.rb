require 'rails_helper'

describe Accounts::Ledgers::PullOpeningBalanceService do
  include_context 'session_setup'



  before do
    @new_branch = create(:branch)

    @ledger = create(:ledger)
    @ledger_balance_org = create(:ledger_balance_org,fy_code: 7273, ledger_id: @ledger.id)
    @ledger_balance_1 = create(:ledger_balance, fy_code: 7273, ledger_id: @ledger.id)
    @ledger_balance_2 = create(:ledger_balance, closing_balance: 2000, branch_id: @new_branch.id, fy_code: 7273, ledger_id: @ledger.id)



    # considering old fy code
    allow_any_instance_of(Accounts::Ledgers::PullOpeningBalanceService).to receive(:get_fy_code).and_return(7374)
    allow_any_instance_of(Accounts::Ledgers::PopulateLedgerDailiesService).to receive(:get_fy_code).and_return(7374)

    subject {Accounts::Ledgers::PullOpeningBalanceService.new(@new_branch.id)}

    @ledger_balance_org.update_attributes(closing_balance: 7000)
    @ledger_balance_1.update_attributes(closing_balance: 5000)
    @ledger_balance_2.update_attributes(closing_balance: 2000)
  end

  describe '.process' do
    it "pulls opening balance for the ledgers of client accounts in branch" do
      subject.process
      UserSession.selected_branch_id = @new_branch.id
      expect(LedgerBalance.unscoped.where(ledger_id: @ledger.id).count).to eq(6)
      expect(@ledger.closing_balance).to eq(2000)

      UserSession.selected_branch_id = 0
      expect(@ledger.closing_balance).to eq(7000)
    end
  end
end
