class CreateMandalaBill < ActiveRecord::Migration
  def change
    create_table :bill do |t|
      t.string :bill_no
      t.string :bill_date
      t.string :bill_type
      t.string :clearance_date
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
      t.string :transaction_date
      t.string :cust_type
      t.string :cr_customer_code
      t.string :bill_reverse
      t.string :mutual_tag
      t.string :mutual_no
      t.string :fiscal_year
      t.string :transaction_fee
      t.string :settlement_tag
      t.string :net_rev_amt
      t.string :net_pay_amt
      t.string :total_demat_amount
      t.string :total_nt_amount
    end
  end
end
