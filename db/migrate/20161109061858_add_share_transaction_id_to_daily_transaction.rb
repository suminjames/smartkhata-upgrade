class AddShareTransactionIdToDailyTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :daily_transaction, :share_transaction_id, :integer
  end
end
