class CreateReceiptPaymentSlip < ActiveRecord::Migration
  def change
    create_table :receipt_payment_slip do |t|
      t.string :title
      t.string :customer_code
      t.string :currency_code
      t.decimal :amount, precision: 15, scale: 2
      t.string :entered_by
      t.date :entered_date
      t.string :fiscal_year
      t.string :remarks
      t.string :payment_type
      t.string :ac_code
      t.string :slip_no
      t.string :slip_date
      t.string :slip_type
      t.string :manual_slip_no
      t.string :settlement_tag
      t.string :voucher_no
      t.string :voucher_code
      t.string :supplier_id
      t.integer :transaction_no, limit: 8
      t.string :void
      t.string :bill_no
      t.string :pay_to
      t.string :cheque_printed
      t.date :issue_date
    end
  end
end
