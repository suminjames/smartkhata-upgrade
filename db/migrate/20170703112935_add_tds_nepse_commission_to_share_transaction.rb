class AddTdsNepseCommissionToShareTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :share_transactions,:tds, :decimal, precision: 15, scale: 4, default: 0
    add_column :share_transactions,:nepse_commission, :decimal, precision: 15, scale: 4, default: 0
  end
end
