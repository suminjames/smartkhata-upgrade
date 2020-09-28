class AddSettlementDateToShareTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :share_transactions, :settlement_date, :date
  end
end
