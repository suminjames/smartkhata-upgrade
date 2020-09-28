class FixColumnNamesLedgerDailies < ActiveRecord::Migration
  def change
    rename_column :ledger_dailies, :opening_blnc, :opening_balance
    rename_column :ledger_dailies, :closing_blnc, :closing_balance
  end
end
