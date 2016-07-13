# == Schema Information
#
# Table name: sms_messages
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  phone                  :string
#  phone_type             :integer          default("0")
#  sms_type               :integer          default("0")
#  credit_used            :integer
#  remarks                :integer
#  transaction_message_id :integer
#  creator_id             :integer
#  updater_id             :integer
#  fy_code                :integer
#  branch_id              :integer
#

require 'test_helper'

class SmsMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
