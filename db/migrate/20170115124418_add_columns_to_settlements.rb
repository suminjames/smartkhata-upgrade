class AddColumnsToSettlements < ActiveRecord::Migration[4.2]
  def change
    add_column :settlements, :belongs_to_batch_payment, :boolean
    add_column :settlements, :cash_amount, :decimal, precision: 15, scale: 2
  end
end
