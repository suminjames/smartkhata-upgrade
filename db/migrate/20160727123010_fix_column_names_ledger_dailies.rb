class FixColumnNamesLedgerDailies < ActiveRecord::Migration[4.2]
  def change
    rename_column :ledger_dailies, :opening_blnc, :opening_balance
    rename_column :ledger_dailies, :closing_blnc, :closing_balance
  end
end
