# == Schema Information
#
# Table name: payment_transactions
#
#  id               :integer          not null, primary key
#  amount           :string
#  status           :integer
#  response_code    :string
#  response_message :string
#  start_time       :string
#  end_time         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe PaymentTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
