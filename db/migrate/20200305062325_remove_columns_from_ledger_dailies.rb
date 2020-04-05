class RemoveColumnsFromLedgerDailies < ActiveRecord::Migration
  def up
    remove_column :ledger_dailies, :opening_balance
    remove_column :ledger_dailies, :closing_balance
  end
end
