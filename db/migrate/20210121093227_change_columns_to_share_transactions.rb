class ChangeColumnsToShareTransactions < ActiveRecord::Migration[4.2]
  def change
    change_column :share_transactions, :share_amount, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :commission_amount, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :dp_fee, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :cgt, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :bank_deposit, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :amount_receivable, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :closeout_amount, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :purchase_price, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :capital_gain, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :adjusted_sell_price, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :tds, :decimal, :precision => 15, :scale => 4
    change_column :share_transactions, :nepse_commission, :decimal, :precision => 15, :scale => 4
  end
end
