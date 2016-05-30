class CreateShareTransactions < ActiveRecord::Migration
  def change
    create_table :share_transactions do |t|
      t.decimal :contract_no, precision: 18, scale: 0
      t.integer :buyer
      t.integer :seller
      t.integer :raw_quantity # raw quantity is the quantity as per the order
      t.integer :quantity # quantity has the adjustment for closeout
      t.decimal :share_rate , precision: 10, scale: 4, default: 0
      t.decimal :share_amount, precision: 15, scale: 4, default: 0
      t.decimal :sebo, precision: 15, scale: 4, default: 0
      t.string :commission_rate
      t.decimal :commission_amount, precision: 15, scale: 4, default: 0
      t.decimal :dp_fee, precision: 15, scale: 4, default: 0
      t.decimal :cgt, precision: 15, scale: 4, default: 0
      t.decimal :net_amount, precision: 15, scale: 4, default: 0 # net amount is the amount irrespective of closeout
      t.decimal :bank_deposit, precision: 15, scale: 4, default: 0
      t.integer :transaction_type
      t.decimal :settlement_id, precision:18, scale: 0
      t.decimal :base_price, precision: 15, scale: 4, default: 0
      t.decimal :amount_receivable, precision:15, scale: 4, default: 0 # amount receivable accounts the closeout adjustment (without additional charges)
      t.decimal :closeout_amount, precision:15, scale: 4, default:0
      # new filed addition in new cm report
      t.string :remarks
      t.decimal :purchase_price, precision:15, scale: 4, default: 0
      t.decimal :capital_gain, precision:15, scale: 4, default: 0
      t.decimal :adjusted_sell_price, precision:15, scale: 4, default: 0


      t.date :date
      t.date :deleted_at
      t.timestamps null: false
      t.integer :nepse_chalan_id, index: true
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :branch_id, index: true
      t.references :voucher, index: true
      t.references :bill , index: true
      t.references :client_account , index: true
      t.references :isin_info , index: true
    end
  end
end
