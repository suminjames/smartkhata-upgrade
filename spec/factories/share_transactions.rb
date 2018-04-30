FactoryBot.define do
  factory :share_transaction do
    client_account
    contract_no 201611284117936
    date "2016-11-28"
    isin_info
    bill nil
    raw_quantity 185
    quantity 185
    share_rate 626
    buyer 99
    seller 100
    settlement_id nil
    share_amount 115810.0
    sebo 17.315
    commission_rate "0.55"
    commission_amount 636.955
    dp_fee 25
    net_amount 116489.27 #that client pays or receives, pays in this case
    bank_deposit 116031.1406 #that nepse needs in purchase case
    transaction_type 0

    # sales as of floorsheet
    factory :sales_share_transaction do
      amount_receivable 0
      net_amount 116489.27
      bank_deposit 116489.27
      transaction_type 1
      buyer 100
      seller 99

      factory :sales_share_transaction_processed do
        net_amount 115130.6726
        amount_receivable 115588.802

        factory :sales_share_transaction_processed_with_closeout do
          amount_receivable 100564.802
          closeout_amount 15024.0
          quantity 165
        end

        factory :sales_share_transaction_processed_with_full_closeout do
          quantity 0
          amount_receivable "-23383.198"
          closeout_amount 138972
        end
      end

    end

    factory :buy_transaction_processed_with_closeout do
      closeout_amount 15024.0
      quantity 165
    end

    factory :balancing_transaction do
      quantity 20
      share_rate 637
      share_amount 12740.0
      commission_rate "0.60"
      sebo 1.911
      commission_amount 76.44
      net_amount 12818.351 #that client pays or receives, pays in this case
      bank_deposit 12766.3718 #that nepse needs in purchase case
    end
  end
end
