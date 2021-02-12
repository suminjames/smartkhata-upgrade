# == Schema Information
#
# Table name: esewa_payments
#
#  id              :integer          not null, primary key
#  service_charge  :decimal(, )
#  delivery_charge :decimal(, )
#  tax_amount      :decimal(, )
#  success_url     :string
#  failure_url     :string
#  response_ref    :string
#  response_amount :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :esewa_payment do
    receipt_transaction nil
    username "MyString"
    response "MyString"
    response_code "MyString"
    status "MyString"
    request_sent_at "MyString"
    response_received_at "MyString"
  end
end
