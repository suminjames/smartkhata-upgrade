class CreateSalesSettlements < ActiveRecord::Migration[4.2]
  def change
    create_table :sales_settlements do |t|
      t.decimal :settlement_id, precision: 18, scale: 0
      t.integer :status, default: 0
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true

      t.date :settlement_date
      t.timestamps null: false
    end
  end
end
