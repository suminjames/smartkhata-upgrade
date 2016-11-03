class CreateTempDailyTransaction < ActiveRecord::Migration
  def change
    create_table :temp_daily_transaction do |t|
      t.integer :transaction_no, limit: 8
      t.string :company_code
      t.integer :buyer_broker_no
      t.integer :seller_broker_no
      t.string :customer_name
      t.integer :quantity
      t.integer :rate
      t.decimal :amount, precision: 15, scale: 2
      t.decimal :stock_commission, precision: 15, scale: 2
      t.decimal :bank_deposit, precision: 15, scale: 2
      t.date :transaction_date
      t.string :transaction_bs_date
      t.string :fiscal_year
      t.string :nepse_code
    end
  end
end
