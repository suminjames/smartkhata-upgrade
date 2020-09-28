class AddSettlementDateToShareTransaction < ActiveRecord::Migration
  def change
    add_column :share_transactions, :settlement_date, :date
  end
end
