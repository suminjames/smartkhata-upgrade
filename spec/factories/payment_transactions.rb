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

FactoryGirl.define do
  factory :payment_transaction do
    amount "MyString"
    status 1
    response_code "MyString"
    response_message "MyString"
    start_time "MyString"
    end_time "MyString"
  end
end
