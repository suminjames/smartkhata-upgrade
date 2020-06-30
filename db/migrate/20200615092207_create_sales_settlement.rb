class CreateSalesSettlement < ActiveRecord::Migration
  def change
    create_table :sales_settlements do |t|
      t.bigint :settlement_id
      t.datetime :tradestartdate
      t.datetime :tradeenddate
      t.datetime :secpayindt
      t.datetime :secpayoutdt
      t.bigint :contract_no
      t.string :scriptshortname
      t.integer :scriptnumber
      t.string :clientcode
      t.integer :quantity
      t.integer :cmid
      t.bigint :sellerodrno

      t.timestamps null: false
    end
  end
end
