class CreateDailyTransaction < ActiveRecord::Migration
  def change
    create_table :daily_transaction do |t|
      t.string :transaction_no
      t.string :job_no
      t.string :share_code
      t.string :quantity
      t.string :rate
      t.string :customer_code
      t.string :broker_no
      t.string :broker_job_no
      t.string :self_broker_no
      t.string :transaction_date
      t.string :settlement_date
      t.string :transaction_type
      t.string :base_price
      t.string :transaction_bs_date
      t.string :settlement_bs_date
      t.string :company_code
      t.string :seller_customer_code
      t.string :buyer_bill_no
      t.string :seller_bill_no
      t.string :deposited_date
      t.string :receipt_date
      t.string :client_account_no
      t.string :cash_account_no
      t.string :remarks
      t.string :cancel_tag
      t.string :chalan_no
      t.string :buyer_order_no
      t.string :seller_order_no
      t.string :broker_transaction
      t.string :other_broker_transaction
      t.string :fiscal_year
      t.string :base_price_date
      t.string :transaction_status
      t.string :nepse_commission
      t.string :sebo_commission
      t.string :tds
      t.string :capital_gain
      t.string :capital_gain_tax
      t.string :adjusted_purchase_price
      t.string :payout_tag
      t.string :closeout_quantity
      t.string :closeout_amount
      t.string :closeout_tag
      t.string :receivable_amount
      t.string :settlement_id
      t.string :voucher_no
      t.string :voucher_code
      t.string :closeout_voucher_tag
      t.string :closeout_voucher_no
    end
  end
end
