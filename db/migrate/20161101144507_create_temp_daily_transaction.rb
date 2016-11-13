class CreateTempDailyTransaction < ActiveRecord::Migration
  def change
    create_table :temp_daily_transaction do |t|
      t.string :transaction_no
      t.string :company_code
      t.string :buyer_broker_no
      t.string :seller_broker_no
      t.string :customer_name
      t.string :quantity
      t.string :rate
      t.string :amount
      t.string :stock_commission
      t.string :bank_deposit
      t.string :transaction_date
      t.string :transaction_bs_date
      t.string :fiscal_year
      t.string :nepse_code
    end
  end
end
