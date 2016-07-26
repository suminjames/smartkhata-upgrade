# == Schema Information
#
# Table name: ledger_dailies
#
#  id              :integer          not null, primary key
#  date            :date
#  dr_amount       :decimal(15, 4)   default("0.0")
#  cr_amount       :decimal(15, 4)   default("0.0")
#  opening_balance :decimal(15, 4)   default("0.0")
#  closing_balance :decimal(15, 4)   default("0.0")
#  date_bs         :string
#  fy_code         :integer
#  creator_id      :integer
#  updater_id      :integer
#  ledger_id       :integer
#  branch_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class LedgerDailyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
