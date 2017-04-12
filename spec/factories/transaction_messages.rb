FactoryGirl.define do
  factory :transaction_message do
    client_account
    sms_message "MyString"
    transaction_date Time.now
  end
end