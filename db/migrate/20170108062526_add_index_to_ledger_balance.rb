class AddIndexToLedgerBalance < ActiveRecord::Migration[4.2]
  def change
    add_index :ledger_balances, [:fy_code, :branch_id, :ledger_id], unique: true
  end
end
