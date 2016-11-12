class AddLedgerIdToChartOfAccount < ActiveRecord::Migration
  def change
    add_column :chart_of_account, :ledger_id, :integer
  end
end
