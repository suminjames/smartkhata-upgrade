FactoryBot.define do
  factory :bill do
    sequence (:bill_number)
    client_name 'Harold Hill'
    net_amount '9000'
    balance_to_pay  { net_amount }
    bill_type 0
    status :pending
    special_case 0
    fy_code '7374'
    date { 3.day.ago.to_date }
    date_bs { CustomDateModule.ad_to_bs(3.days.ago.to_date) } #replace this with 3 working days before
    settlement_date { Time.now.to_date }
    client_account
    branch
    creator_id { User.first.id || create(:user).id }
    updater_id { User.first.id || create(:user).id }
    factory :sales_bill do
      bill_type :sales

      factory :sales_bill_with_transaction do
        after(:create) do |bill|
          create_list(:sales_share_transaction, 1, bill: bill)
        end
      end
    end

    factory :sales_bill_with_closeout do
      bill_type :sales
      after(:create) do |bill|
        create_list(:sales_share_transaction_with_closeout, 1, bill: bill)
      end
    end

    factory :purchase_bill do
      bill_type :purchase
    end
  end
end
