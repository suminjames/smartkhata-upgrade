class AddOpeningBalanceTypeToLedgerBalance < ActiveRecord::Migration
  def change
    add_column :ledger_balances, :opening_balance_type, :integer
  end
end
