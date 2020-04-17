class AddLedgerIdToChartOfAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :chart_of_account, :ledger_id, :integer
  end
end
