class AddIndexToReceiptPaymentSlip < ActiveRecord::Migration[4.2]
  def change
    add_index :receipt_payment_slip, :voucher_no
    add_index :receipt_payment_slip, :voucher_code
  end
end
