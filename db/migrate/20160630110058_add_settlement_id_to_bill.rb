class AddSettlementIdToBill < ActiveRecord::Migration
  def change
    add_column :bills, :settlement_id, :bigint, index: true
  end
end
