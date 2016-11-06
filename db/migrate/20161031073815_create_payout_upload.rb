class CreatePayoutUpload < ActiveRecord::Migration
  def change
    create_table :payout_upload do |t|
      t.string :transaction_no
      t.string :transaction_type
      t.string :transaction_date
      t.string :company_code
      t.string :quantity
      t.string :rate
      t.string :nepse_commission
      t.string :sebo_commission
      t.string :tds
      t.string :capital_gain
      t.string :capital_gain_tax
      t.string :adjusted_purchase_price
      t.string :closeout_amount
      t.string :closeout_quantity
      t.string :settlement_id
      t.string :receivable_amount
    end
  end
end
