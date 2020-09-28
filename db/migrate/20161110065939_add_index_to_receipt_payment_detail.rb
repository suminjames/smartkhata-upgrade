class AddIndexToReceiptPaymentDetail < ActiveRecord::Migration
  def change
    add_index :receipt_payment_detail, :fiscal_year
    add_index :receipt_payment_detail, :slip_type
    add_index :receipt_payment_detail, :slip_no
    add_index :receipt_payment_detail, :cheque_no
  end
end
