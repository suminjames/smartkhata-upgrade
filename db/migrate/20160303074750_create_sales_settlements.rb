class CreateSalesSettlements < ActiveRecord::Migration
  def change
    create_table :sales_settlements do |t|
      t.decimal :settlement_id, precision: 18, scale: 0
      t.integer :status, default: 0
      t.date :settlement_date
      t.timestamps null: false
    end
  end
end
