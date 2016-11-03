class CreateReceiptPaymentDetail < ActiveRecord::Migration
  def change
    create_table :receipt_payment_detail do |t|
      t.integer :slip_no, limit: 8
      t.string :slip_type
      t.string :fiscal_year
      t.integer :cheque_no, limit: 8
      t.string :bank_code
      t.decimal :amount, precision: 15, scale: 4
      t.string :remarks
      t.string :customer_code
      t.string :bill_no
    end
  end
end
