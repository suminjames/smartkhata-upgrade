# == Schema Information
#
# Table name: nepse_settlements
#
#  id              :integer          not null, primary key
#  settlement_id   :decimal(18, )
#  status          :integer          default(0)
#  creator_id      :integer
#  updater_id      :integer
#  settlement_date :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class SalesSettlementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
