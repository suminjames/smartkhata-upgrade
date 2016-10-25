FactoryGirl.define do

  factory :cheque_entry do
    sequence(:cheque_number)
    bank_account

    after_create do |cheque_entry|
      cheque_entry.particulars << create(:debit_particular)
      cheque_entry.particulars << create(:credit_particular)
    end

  end

  # defines particular
  factory :particular do
    amount 5000
    fy_code 7374
    branch_id 1
    voucher

    # trait :with_settlement do
    #   after_create do |particular|
    #     particular.settlements << create(:settlement)
    #   end
    # end

    factory :debit_particular do
      transaction_type 0
    end

    factory :credit_particular do
      transaction_type 1
    end

  end

  factory :voucher do
    fy_code 7374
    date_bs '2073-09-24'
    voucher_type 0
    voucher_status 1
    # branch: two
    branch_id 1
  end

  factory :bank_account do
    sequence(:account_number)
    bank_branch "chabahil"
    branch_id 1

    branch
  end

  factory :branch do
    code 'BR-1'
    address 'MyString'
  end
end