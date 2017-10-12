require 'rails_helper'

describe Accounts::Ledgers::ClosingBalanceService do
  include_context 'session_setup'

  before do
    @new_branch = create(:branch)
    @ledger = create(:ledger)
    @ledger_balance_org = create(:ledger_balance_org, opening_balance: 2000, fy_code: @fy_code, ledger_id: @ledger.id)
    @ledger_balance = create(:ledger_balance, opening_balance: 5000, branch_id: @new_branch.id, fy_code: @fy_code, ledger_id: @ledger.id)
    @particular = create(:particular, ledger_id: @ledger.id, branch_id: @new_branch.id, amount: 3000)
    subject {Accounts::Ledgers::ClosingBalanceService.new}
  end

  describe '.patch_closing_balance' do
    it 'patches closing balance' do
      UserSession.selected_branch_id = @new_branch.id
      subject.patch_closing_balance(@ledger,branch_id: @new_branch.id, fy_code: @fy_code)
      expect(@ledger.closing_balance).to eq(8000)

      UserSession.selected_branch_id = 0
      expect(@ledger.closing_balance).to eq(5000)
    end
  end
end