FactoryBot.define do
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
      master_setup_commission_info.commission_details << FactoryBot.create(:master_setup_commission_detail)
    end
  end

  factory :user do
    sequence(:username, 'a') { |n| "testuser#{n}" }
    sequence(:email, 'a') { |n| "testuser-#{n}@gmail.com" }
    password "password"
    password_confirmation "password"
    confirmed_at Date.today
    role {User.roles[:admin]}
    branch
  end

  factory :cheque_entry do
    sequence(:cheque_number)
    status :void
    cheque_issued_type :payment
    amount 5000
    bank_account
    cheque_date '2016-7-12'
    branch
    beneficiary_name 'subas'

    factory :receipt_cheque_entry do
      cheque_issued_type :receipt
      additional_bank_id 2
    end
  end

  # defines particular
  factory :particular do
    amount 5000
    fy_code 7374
    branch
    voucher
    ledger
    transaction_type 0
    cheque_number nil

    factory :debit_particular do
      transaction_type 0
      ledger
    end

    factory :credit_particular_non_bank do
      transaction_type 1
      ledger
    end

    # due to excessive usage did not refactored
    factory :credit_particular do
      transaction_type 1
      association :ledger, factory: :bank_ledger
    end

    factory :bank_particular do
      association :ledger, factory: :bank_ledger

      factory :bank_cr_particular do
        transaction_type 1
      end
    end
  end





  factory :branch do
    sequence(:code) { |n| "Branch-#{n}" }
    address 'KTM'
  end

  factory :bank do
    sequence(:name) { |n| "Bank-#{n}" }
    sequence(:bank_code) { |n| "#{n}" }
    address 'AnotherString'
    contact_no 'AnotherString'
  end

  factory :ledger do
    name 'Ledger'
    # group_id 234
    group

    factory :bank_ledger do
      name 'Bank'
      bank_account
    end
  end
  factory :ledger_balance do
    opening_balance 0
    # opening_balance_type "dr"
    # closing_balance 5000  taken care in callback
    dr_amount 5000
    cr_amount 0
    branch
    fy_code '7374'

    factory :ledger_balance_org do
      branch_id nil
    end
  end

  factory :client_account do
    name 'Dedra Sorenson'
    mobile_number '9851182852'
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
    branch

    # association :creator, factory: :user
    # association :updater, factory: :user

    factory :client_account_without_nepse_code do
      nepse_code nil

      factory :corporate_client_account_without_nepse_code do
        client_type 1 
      end

    end    
  end

  factory :isin_info do
    company 'Test Pvt. Ltd.'
    sector 'technology'
    isin 'DAN'
  end
 
  factory :broker_profile do
    broker_name "afggf"
    broker_number 123
    locale 0

    factory :master_broker_profile, class: 'MasterSetup::BrokerProfile' do
    end
  end

  factory :employee_account do
    name "ggghf"
    email "test@example.com"
  end

  factory :settlement do
    date_bs "2074/03/05"
  end

  factory :branch_permission do
  end

  factory :particulars do
  end

  factory :tenant do
    full_name 'Danphe'
    address  'Kupondole'
    phone_number '99999'
    fax_number '0989'
    pan_number '9909'
  end
  
end
