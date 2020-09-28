class ChangeMoneyFieldsInBalances < ActiveRecord::Migration[4.2]
  def up
    change_column :ledger_balances, :opening_balance, :decimal, :precision => 12, :scale => 2
    change_column :ledger_balances, :closing_balance, :decimal, :precision => 12, :scale => 2
    change_column :ledger_balances, :dr_amount, :decimal, :precision => 12, :scale => 2
    change_column :ledger_balances, :cr_amount, :decimal, :precision => 12, :scale => 2
    change_column :ledger_dailies, :dr_amount, :decimal, :precision => 12, :scale => 2
    change_column :ledger_dailies, :cr_amount, :decimal, :precision => 12, :scale => 2
  end
end

