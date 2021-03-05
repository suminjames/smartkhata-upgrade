FactoryGirl.define do
  factory :esewa_transaction_verification do
    esewa_receipt nil
    request_sent_at "MyString"
    response_received_at "MyString"
    status 1
  end
end
