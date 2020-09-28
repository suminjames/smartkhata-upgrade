class RenameSalesSettlementToNepseSettlement < ActiveRecord::Migration[4.2]
  def change
    rename_table :sales_settlements, :nepse_settlements
    add_column :nepse_settlements, :type, :string, index: true
  end
end
