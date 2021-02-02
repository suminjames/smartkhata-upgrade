FactoryBot.define do
  factory :bank_account do
    sequence(:account_number)
    bank_branch { "chabahil" }
    branch_id { 1 }
    bank_id { 1 }
    default_for_payment { true }
    default_for_receipt { true }
    current_user_id { User.first&.id || create(:user).id }
    ledger
    # association :ledger, factory: :bank_ledger
    #   the above line wont work as it will cause loop
  end
end
