# == Schema Information
#
# Table name: transaction_messages
#
#  id                :integer          not null, primary key
#  sms_message       :string
#  transaction_date  :date
#  sms_status        :integer          default("0")
#  email_status      :integer          default("0")
#  bill_id           :integer
#  client_account_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :date
#  sent_sms_count    :integer          default("0")
#  sent_email_count  :integer          default("0")
#  remarks_email     :string
#  remarks_sms       :string
#

require 'test_helper'

class TransactionMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
