class AddSalesSettlementIdToBill < ActiveRecord::Migration[4.2]
  def change
    add_column :bills, :sales_settlement_id, :bigint, index: true
  end
end
