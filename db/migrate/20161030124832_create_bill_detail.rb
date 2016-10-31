class CreateBillDetail < ActiveRecord::Migration
  def change
    create_table :bill_detail do |t|
      t.string :bill_no
      t.integer :no_of_shares
      t.string :company_code
      t.integer :rate_per_share
      t.decimal :amount, precision: 15, scale: 4
      t.decimal :commission_rate, precision: 15, scale: 4
      t.decimal :commission_amount, precision: 15, scale: 4
      t.string :budget_code
      t.string :item_name
      t.integer :item_rate
      t.integer :transaction_no, limit: 8
      t.string :share_code
      t.decimal :capital_gain, precision: 15, scale: 4
      t.integer :name_transfer_rate
      t.integer :base_price
      t.decimal :mutual_capital_gain, precision: 15, scale: 4
      t.string :fiscal_year
      t.decimal :transaction_fee, precision: 15, scale: 4
      t.string :transaction_type
      t.decimal :demat_rate, precision: 15, scale: 4
      t.integer :no_of_shortage_shares
      t.decimal :close_out_amount, precision: 15, scale: 4
    end
  end
end
