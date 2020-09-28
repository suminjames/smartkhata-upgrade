class AddSettlementIdToReceiptPaymentSlip < ActiveRecord::Migration[4.2]
  def change
    add_column :receipt_payment_slip, :settlement_id, :integer
  end
end
