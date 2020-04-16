class AddOpeningBalanceTypeToLedgerBalance < ActiveRecord::Migration[4.2]
  def change
    add_column :ledger_balances, :opening_balance_type, :integer
  end
end
