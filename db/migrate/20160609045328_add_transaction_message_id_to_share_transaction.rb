class AddTransactionMessageIdToShareTransaction < ActiveRecord::Migration
  def change
    add_column :share_transactions, :transaction_message_id, :integer, index: true
  end
end
