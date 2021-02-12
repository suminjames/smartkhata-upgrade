# == Schema Information
#
# Table name: receipt_transactions
#
#  id                              :integer          not null, primary key
#  amount                          :decimal(, )
#  status                          :integer
#  transaction_id                  :string
#  request_sent_at                 :datetime
#  response_received_at            :datetime
#  response_code                   :integer
#  validation_request_sent_at      :datetime
#  validation_response_received_at :datetime
#  validation_response_code        :integer
#  transaction_date                :date
#  payable_id                      :integer
#  payable_type                    :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'rails_helper'

RSpec.describe ReceiptTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
