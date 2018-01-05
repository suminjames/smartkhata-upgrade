require 'rails_helper'

describe Accounts::Ledgers::PopulateLedgerDailiesService do
  include_context 'session_setup'

  before do
    @new_branch = create(:branch)
    @ledger = create(:ledger)
    @ledger_balance_org = create(:ledger_balance_org, opening_balance: 3000, fy_code: @fy_code, ledger_id: @ledger.id)
    @ledger_daily_org = create(:ledger_daily, fy_code: @fy_code, ledger_id: @ledger.id, branch_id: nil, date: '2016-8-16')
    @ledger_balance = create(:ledger_balance, opening_balance: 5000, branch_id: @new_branch.id, fy_code: @fy_code, ledger_id: @ledger.id)
    @ledger_daily = create(:ledger_daily, fy_code: @fy_code, ledger_id: @ledger.id, branch_id: @new_branch.id, date: '2016-8-16')
    @particular = create(:particular, ledger_id: @ledger.id, branch_id: @new_branch.id, amount: 4000, transaction_date: '2016-8-16')
    subject {Accounts::Ledgers::PopulateLedgerDailiesService.new}
  end

  describe '.patch_ledger_dailies' do
    it 'patches ledger dailies' do
      # subject.patch_ledger_dailies(@ledger, false, branch_id = @new_branch.id, fy_code = @fy_code)
      # expect(@ledger.closing_balance).to eq(9000)
    end
  end
end
