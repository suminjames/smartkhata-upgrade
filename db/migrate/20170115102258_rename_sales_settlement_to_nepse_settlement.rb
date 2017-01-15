class RenameSalesSettlementToNepseSettlement < ActiveRecord::Migration
  def change
    rename_table :sales_settlements, :nepse_settlements
    add_column :nepse_settlements, :settlement_type, :integer, default: 0
  end
end
