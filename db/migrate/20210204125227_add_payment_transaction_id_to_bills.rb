class AddPaymentTransactionIdToBills < ActiveRecord::Migration
  def change
    add_reference :bills, :payment_transaction, index: true, foreign_key: true
  end
end
