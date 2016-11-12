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
end
