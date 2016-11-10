class AddIndexToReceiptPaymentSlip < ActiveRecord::Migration
  def change
    add_index :receipt_payment_slip, :voucher_no
    add_index :receipt_payment_slip, :voucher_code
  end
end
