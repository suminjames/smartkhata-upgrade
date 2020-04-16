class AddChequeEntryToReceiptPaymentDetail < ActiveRecord::Migration[4.2]
  def change
    add_column :receipt_payment_detail, :cheque_entry_id, :integer
  end
end
