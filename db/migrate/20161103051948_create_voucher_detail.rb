class CreateVoucherDetail < ActiveRecord::Migration[4.2]
  def change
    create_table :voucher_detail do |t|
      t.string :voucher_no
      t.string :voucher_code
      t.string :ac_code
      t.string :sub_code
      t.string :particulars
      t.string :currency_code
      t.string :amount
      t.string :conversion_rate
      t.string :nrs_amount
      t.string :transaction_type
      t.string :cost_revenue_code
      t.string :invoice_no
      t.string :vou_period
      t.string :against_ac_code
      t.string :against_sub_code
      t.string :cheque_no
      t.string :fiscal_year
      t.string :serial_no
    end
  end
end
