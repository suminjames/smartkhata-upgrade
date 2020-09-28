class CreateBillDetail < ActiveRecord::Migration
  def change
    create_table :bill_detail do |t|
      t.string :bill_no
      t.string :no_of_shares
      t.string :company_code
      t.string :rate_per_share
      t.string :amount
      t.string :commission_rate
      t.string :commission_amount
      t.string :budget_code
      t.string :item_name
      t.string :item_rate
      t.string :transaction_no
      t.string :share_code
      t.string :capital_gain
      t.string :name_transfer_rate
      t.string :base_price
      t.string :mutual_capital_gain
      t.string :fiscal_year
      t.string :transaction_fee
      t.string :transaction_type
      t.string :demat_rate
      t.string :no_of_shortage_shares
      t.string :close_out_amount
    end
  end
end
