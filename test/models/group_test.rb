# == Schema Information
#
# Table name: groups
#
#  id                :integer          not null, primary key
#  name              :string
#  parent_id         :integer
#  report            :integer
#  sub_report        :integer
#  for_trial_balance :boolean          default("false")
#  creator_id        :integer
#  updater_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
