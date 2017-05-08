FactoryGirl.define do
  factory :bank_account do
    sequence(:account_number)
    bank_branch "chabahil"
    branch_id 1
    bank

    ledger
    # association :ledger, factory: :bank_ledger
    #   the above line wont work as it will cause loop
  end
end
