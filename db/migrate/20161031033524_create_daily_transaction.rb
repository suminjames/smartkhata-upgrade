class CreateDailyTransaction < ActiveRecord::Migration
  def change
    create_table :daily_transaction do |t|
      t.integer :transaction_no, limit: 8
      t.integer :job_no
      t.string :share_code
      t.integer :quantity, limit: 8
      t.integer :rate
      t.integer :customer_code
      t.integer :broker_no
      t.integer :broker_job_no
      t.integer :self_broker_no
      t.date :transaction_date
      t.date :settlement_date
      t.string :transaction_type
      t.integer :base_price
      t.string :transaction_bs_date
      t.string :settlement_bs_date
      t.string :company_code
      t.integer :seller_customer_code
      t.string :buyer_bill_no
      t.string :seller_bill_no
      t.date :deposited_date
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
      t.date :base_price_date
      t.string :transaction_status
      t.decimal :nepse_commission, precision: 15, scale: 4
      t.decimal :sebo_commission, precision: 15, scale: 4
      t.decimal :tds, precision: 15, scale: 4
      t.decimal :capital_gain, precision: 15, scale: 4
      t.decimal :capital_gain_tax, precision: 15, scale: 4
      t.decimal :adjusted_purchase_price, precision: 15, scale: 4
      t.string :payout_tag
      t.integer :closeout_quantity
      t.decimal :closeout_amount, precision: 15, scale: 4
      t.string :closeout_tag
      t.decimal :receivable_amount, precision: 15, scale: 4
      t.integer :settlement_id, limit: 8
      t.string :voucher_no
      t.string :voucher_code
      t.string :closeout_voucher_tag
      t.string :closeout_voucher_no
    end
  end
end
