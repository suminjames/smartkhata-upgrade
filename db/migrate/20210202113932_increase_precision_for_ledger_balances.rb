class IncreasePrecisionForLedgerBalances < ActiveRecord::Migration
  def change
    change_column :ledger_balances, :opening_balance, :decimal, :precision => 15, :scale => 2
    change_column :ledger_balances, :closing_balance, :decimal, :precision => 15, :scale => 2
    change_column :ledger_balances, :dr_amount, :decimal, :precision => 15, :scale => 2
    change_column :ledger_balances, :cr_amount, :decimal, :precision => 15, :scale => 2
    change_column :ledger_dailies, :dr_amount, :decimal, :precision => 15, :scale => 2
    change_column :ledger_dailies, :cr_amount, :decimal, :precision => 15, :scale => 2
  end
end
