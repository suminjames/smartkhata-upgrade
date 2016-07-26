# == Schema Information
#
# Table name: settlements
#
#  id                :integer          not null, primary key
#  name              :string
#  amount            :decimal(, )
#  date_bs           :string
#  description       :string
#  settlement_type   :integer
#  fy_code           :integer
#  settlement_number :integer
#  client_account_id :integer
#  vendor_account_id :integer
#  creator_id        :integer
#  updater_id        :integer
#  receiver_name     :string
#  voucher_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  branch_id         :integer
#

require 'test_helper'

class SettlementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
