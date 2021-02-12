class AddReceiptTransactionIdToBills < ActiveRecord::Migration
  def change
    add_reference :bills, :receipt_transaction, index: true, foreign_key: true
  end
end
