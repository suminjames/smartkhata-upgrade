# == Schema Information
#
# Table name: ledger_balances
#
#  id              :integer          not null, primary key
#  opening_balance :decimal(15, 4)   default(0.0)
#  closing_balance :decimal(15, 4)   default(0.0)
#  dr_amount       :decimal(15, 4)   default(0.0)
#  cr_amount       :decimal(15, 4)   default(0.0)
#  fy_code         :integer
#  branch_id       :integer
#  creator_id      :integer
#  updater_id      :integer
#  ledger_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class LedgerBalanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should assign closing balance as opening balance on create" do
    @ledger_balance = create(:ledger_balance, opening_balance: 500, closing_balance: 1500)
    assert_equal 500, @ledger_balance.opening_balance
    assert_equal 500, @ledger_balance.closing_balance
  end

  test "should update closing balance according to opening balance on update" do
    @ledger_balance = create(:ledger_balance, opening_balance: 500)
    @ledger_balance.update(opening_balance: 1000)
    assert_equal 1000, @ledger_balance.opening_balance
    assert_equal 1000, @ledger_balance.closing_balance

    @ledger_balance.update(closing_balance: 6000)
    # change opening balance now
    @ledger_balance.update(opening_balance: 2000)
    assert_equal 2000, @ledger_balance.opening_balance.to_f
    assert_equal 7000, @ledger_balance.closing_balance.to_f

  end

end
