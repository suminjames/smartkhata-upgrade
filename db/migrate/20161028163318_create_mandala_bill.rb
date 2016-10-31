class CreateMandalaBill < ActiveRecord::Migration
  def change
    create_table :bill do |t|
      t.string :bill_no
      t.date :bill_date
      t.string :bill_type
      t.date :clearance_date
      t.string :customer_code
      t.string :bill_bs_date
      t.string :clearance_bs_date
      t.string :vendor_id
      t.string :bill_status
      t.string :voucher_no
      t.string :voucher_code
      t.string :bill_transaction_type
      t.string :chalan_no
      t.string :chalan_form_no
      t.string :group_code
      t.date :transaction_date
      t.string :cust_type
      t.string :cr_customer_code
      t.string :bill_reverse
      t.string :mutual_tag
      t.string :mutual_no
      t.string :fiscal_year
      t.decimal :transaction_fee, precision: 15, scale: 4
      t.string :settlement_tag
      t.decimal :net_rev_amt, precision: 15, scale: 4
      t.decimal :net_pay_amt, precision: 15, scale: 4
      t.decimal :total_demat_amount, precision: 15, scale: 4
      t.decimal :total_nt_amount, precision: 15, scale: 4
    end
  end
end
