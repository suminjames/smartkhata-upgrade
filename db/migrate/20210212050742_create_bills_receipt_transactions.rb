class CreateBillsReceiptTransactions < ActiveRecord::Migration
  def change
    create_table :bills_receipt_transactions do |t|
      t.belongs_to :bill
      t.belongs_to :receipt_transaction
    end
  end
end
