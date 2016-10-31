class CreateBuySettlement < ActiveRecord::Migration
  def change
    create_table :buy_settlement do |t|
      t.integer :transaction_no, limit:8
      t.string :transaction_type
      t.date :transaction_date
      t.string :company_code
      t.integer :quantity
      t.integer :rate
      t.decimal :nepse_commission, precision: 15, scale: 4
      t.decimal :sebo_commission, precision: 15, scale: 4
      t.decimal :tds, precision: 15, scale: 4
      t.integer :settlement_id, limit:8
    end
  end
end
