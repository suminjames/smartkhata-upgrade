FactoryBot.define do
  factory :transaction_message do
    client_account
    sms_message "Saroj bought EBL,100@2900;On 1/23 Bill No7273-79 .Pay Rs 292678.5.BNo 48. sarojk@dandpheit.com"
    transaction_date Time.now
  end
end
