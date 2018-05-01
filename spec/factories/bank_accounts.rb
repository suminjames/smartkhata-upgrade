FactoryBot.define do
  factory :bank_account do
    sequence(:account_number)
    bank_branch "chabahil"
    branch
    bank
    default_for_payment true
    default_for_receipt true

    ledger
    # association :ledger, factory: :bank_ledger
    #   the above line wont work as it will cause loop
  end
end
