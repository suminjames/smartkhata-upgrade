require 'rails_helper'

describe Accounts::Ledgers::ClosingBalanceService do
  include_context 'session_setup'
  let(:current_user) {@user}
  before do
    @new_branch = create(:branch)
    @ledger = create(:ledger, branch_id: @new_branch.id, current_user_id: current_user.id)
    @ledger_balance_org = create(:ledger_balance_org, opening_balance: 2000, fy_code: @fy_code, ledger_id: @ledger.id)
    @ledger_balance = create(:ledger_balance, opening_balance: 5000, branch_id: @new_branch.id, fy_code: @fy_code, ledger_id: @ledger.id)
    @particular = create(:particular, ledger_id: @ledger.id, branch_id: @new_branch.id, amount: 3000)
    subject {Accounts::Ledgers::ClosingBalanceService.new}
  end

  describe '.patch_closing_balance' do
    it 'patches closing balance' do
      subject.patch_closing_balance(@ledger, branch_id: @new_branch.id, fy_code: @fy_code, current_user_id: current_user.id)
      expect(@ledger.closing_balance(@fy_code, @new_branch.id)).to eq(8000)

      expect(@ledger.closing_balance(@fy_code)).to eq(5000)
    end
  end
end