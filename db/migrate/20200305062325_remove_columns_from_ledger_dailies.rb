class RemoveColumnsFromLedgerDailies < ActiveRecord::Migration[4.2]
  def up
    remove_column :ledger_dailies, :opening_balance
    remove_column :ledger_dailies, :closing_balance
  end
end
