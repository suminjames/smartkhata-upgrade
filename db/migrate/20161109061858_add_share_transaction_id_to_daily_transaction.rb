class AddShareTransactionIdToDailyTransaction < ActiveRecord::Migration
  def change
    add_column :daily_transaction, :share_transaction_id, :integer
  end
end
