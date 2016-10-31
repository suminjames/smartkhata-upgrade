class CreatePayoutUpload < ActiveRecord::Migration
  def change
    create_table :payout_upload do |t|
      t.integer :transaction_no, limit: 8
      t.string :transaction_type
      t.date :transaction_date
      t.string :company_code
      t.integer :quantity
      t.integer :rate
      t.decimal :nepse_commission, precision: 15, scale: 4
      t.decimal :sebo_commission, precision: 15, scale: 4
      t.decimal :tds, precision: 15, scale: 4
      t.decimal :capital_gain, precision: 15, scale: 4
      t.decimal :capital_gain_tax, precision: 15, scale: 4
      t.decimal :adjusted_purchase_price, precision: 15, scale: 4
      t.decimal :closeout_amount, precision: 15, scale: 4
      t.integer :closeout_quantity
      t.integer :settlement_id, limit: 8
      t.decimal :receivable_amount, precision: 15, scale: 4
    end
  end
end
