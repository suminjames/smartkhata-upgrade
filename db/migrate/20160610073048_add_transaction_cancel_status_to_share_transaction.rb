class AddTransactionCancelStatusToShareTransaction < ActiveRecord::Migration
  def change
    add_column :share_transactions, :transaction_cancel_status, :integer, :default => 0
  end
end
