FactoryGirl.define do
  factory :master_setup_commission_rate, class: 'MasterSetup::CommissionRate' do
    date_from "2016-11-10"
    date_to "2016-11-10"
    amount_gt "9.99"
    amount_lt_eq "9.99"
    rate "9.99"
    is_flat_rate false
    remarks "MyString"
  end
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
    status :void
    cheque_issued_type :payment
    amount 5000
    bank_account

    factory :receipt_cheque_entry do
      cheque_issued_type :receipt
      additional_bank_id 2
    end
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

    ledger
    # association :ledger, factory: :bank_ledger
  #   the above line wont work as it will cause loop
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

  factory :bill do
    sequence (:bill_number)
    client_name 'Harold Hill'
    net_amount '9000'
    balance_to_pay '9000'
    bill_type 0
    status 2
    special_case 0
    fy_code '7374'
    date { 3.day.ago.to_date }
    date_bs { CustomDateModule.ad_to_bs(3.days.ago.to_date) } #replace this with 3 working days before
    settlement_date { CustomDateModule.ad_to_bs(Time.now.to_date) }
    client_account
    branch_id 1

    factory :sales_bill do
      bill_type :sales
    end

    factory :purchase_bill do
      bill_type :purchase
    end
  end

  factory :client_account do
    name 'Dedra Sorenson'
    phone '55555'
    phone_perm '666666'
    citizen_passport '6789'
    dob '1900-10-10'
    father_mother 'Zephyrus Gemini'
    granfather_father_inlaw 'Pallas Atum'
    address1_perm 'fooland'
    city_perm 'foo-city'
    state_perm 'foo-state'
    country_perm 'foo-country'
    sequence(:nepse_code) { |n| "Nepse-#{n}" }
    sequence (:email) { |n| "n@example.com"}

    ledger
  end
end