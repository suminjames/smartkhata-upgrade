FactoryGirl.define do
  factory :share_transaction do
    client_account
    contract_no 1234
    date Time.now
    isin_info
    bill nil
    quantity 400
    share_rate 200
  end
end