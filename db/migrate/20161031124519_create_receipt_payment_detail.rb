class CreateReceiptPaymentDetail < ActiveRecord::Migration[4.2]
  def change
    create_table :receipt_payment_detail do |t|
      t.string :slip_no
      t.string :slip_type
      t.string :fiscal_year
      t.string :cheque_no
      t.string :bank_code
      t.string :amount
      t.string :remarks
      t.string :customer_code
      t.string :bill_no
    end
  end
end
