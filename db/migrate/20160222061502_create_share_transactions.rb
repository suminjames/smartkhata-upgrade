class CreateShareTransactions < ActiveRecord::Migration
  def change
    create_table :share_transactions do |t|
      t.decimal :contract_no, precision: 18, scale: 0
      t.integer :buyer
      t.integer :seller
      t.integer :quantity
      t.decimal :share_rate , precision: 10, scale: 3, default: 0
      t.decimal :share_amount, precision: 15, scale: 3, default: 0
      t.decimal :sebo, precision: 15, scale: 3, default: 0
      t.string :commission_rate
      t.decimal :commission_amount, precision: 15, scale: 3, default: 0
      t.decimal :dp_fee, precision: 15, scale: 3, default: 0
      t.decimal :cgt, precision: 15, scale: 3, default: 0
      t.decimal :net_amount, precision: 15, scale: 3, default: 0
      t.decimal :bank_deposit, precision: 15, scale: 3, default: 0
      t.integer :transaction_type
      t.decimal :settlement_id, precision:18, scale: 0
      t.decimal :base_price, precision: 15, scale: 3, default: 0
      t.decimal :amount_receivable, precision:15, scale: 3, default: 0
      t.decimal :closeout_amount, precision:15, scale: 3, default:0
      t.date :date
      t.timestamps null: false
      t.references :bill
      t.references :client_account
      t.references :isin_info
    end
  end
end
