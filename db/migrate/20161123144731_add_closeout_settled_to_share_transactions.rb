class AddCloseoutSettledToShareTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :share_transactions, :closeout_settled, :boolean, default: false
  end
end
