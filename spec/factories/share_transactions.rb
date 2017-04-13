FactoryGirl.define do
  factory :share_transaction do
    client_account
    contract_no 1234
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
    bank_deposit 116489.27
    transaction_type 1

    factory :sales_share_transaction do
      buyer 100
      seller 99
      net_amount 115130.6726
      amount_receivable 115588.802
      transaction_type 0

      factory :sales_share_transaction_with_closeout do
        net_amount 100106.6726
        amount_receivable 100564.802
        closeout_amount 15024.0
        quantity 165
      end

      factory :sales_share_transaction_with_full_closeout do
        quantity 0
        net_amount "-23841.3274"
        amount_receivable "-23383.198"
        closeout_amount 138972
      end
    end
  end
end