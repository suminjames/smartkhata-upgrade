class AddSettlementIdToReceiptPaymentSlip < ActiveRecord::Migration
  def change
    add_column :receipt_payment_slip, :settlement_id, :integer
  end
end
