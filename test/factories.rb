FactoryGirl.define do

  factory :user do
    name 'Lachlan'
    email 'idiot@gmail.com'
    encrypted_password { Devise::Encryptor.digest(User, 'password') }
    confirmed_at '2016-05-05'  #stupid error this is needed for login
    role {User.roles[:admin]}
    branch_id 1
  end

  factory :cheque_entry do
    sequence(:cheque_number)
    bank_account
  end

  # defines particular
  factory :particular do
    amount 5000
    fy_code 7374
    branch_id 1
    voucher
    ledger

    factory :debit_particular do
      transaction_type 0
      ledger
    end

    factory :credit_particular do
      transaction_type 1
      association :ledger, factory: :bank_ledger
    end

  end

  factory :voucher do
    fy_code 7374
    date_bs '2073-09-24'
    voucher_type 0
    voucher_status 1
    branch_id 1
  end

  factory :bank_account do
    sequence(:account_number)
    bank_branch "chabahil"
    branch_id 1
    bank
  end

  factory :branch do
    sequence(:code) { |n| "Branch-#{n}" }
    address 'MyString'
  end

  factory :bank do
    sequence(:name) { |n| "Bank-#{n}" }
    sequence(:bank_code) { |n| "#{n}" }
    address 'AnotherString'
    contact_no 'AnotherString'

  end

  factory :ledger do
    name 'Ledger'

    factory :bank_ledger do
      name 'Bank'
      bank_account
    end
  end
end