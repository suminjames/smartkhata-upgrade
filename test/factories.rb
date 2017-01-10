FactoryGirl.define do
  factory :master_setup_commission_detail, class: 'MasterSetup::CommissionDetail' do
    start_amount 0
    limit_amount nil
    commission_rate 1.5
    commission_amount 1.5
  end

  factory :master_setup_commission_info, class: 'MasterSetup::CommissionInfo' do
    start_date "2022-1-1"
    end_date "2022-1-10"
    start_date_bs "MyString"
    end_date_bs "MyString"
    nepse_commission_rate 22.5

    before(:create) do |master_setup_commission_info|
      master_setup_commission_info.commission_details << FactoryGirl.create(:master_setup_commission_detail)
    end
  end

  factory :user do
    name 'Lachlan'
    email 'idiot@gmail.com'
    password 'password'
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
  factory :ledger_balance do
    opening_balance 0
    opening_balance_type "dr"
    # closing_balance 5000  taken care in callback
    dr_amount 5000
    branch_id 1
    fy_code '7374'
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

  factory :isin_info do
    company 'Danphe Infotech'
    sector 'technology'
    isin 'DAN'
  end
end