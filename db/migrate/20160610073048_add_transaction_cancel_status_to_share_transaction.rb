class AddTransactionCancelStatusToShareTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :share_transactions, :transaction_cancel_status, :integer, :default => 0
  end
end
