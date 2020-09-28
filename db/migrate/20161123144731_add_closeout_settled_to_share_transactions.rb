class AddCloseoutSettledToShareTransactions < ActiveRecord::Migration
  def change
    add_column :share_transactions, :closeout_settled, :boolean, default: false
  end
end
