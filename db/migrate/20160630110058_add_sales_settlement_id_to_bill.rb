class AddSalesSettlementIdToBill < ActiveRecord::Migration
  def change
    add_column :bills, :sales_settlement_id, :bigint, index: true
  end
end
