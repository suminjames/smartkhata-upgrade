class CreateSupplierBillDetail < ActiveRecord::Migration
  def change
    create_table :supplier_bill_detail do |t|
      t.string :bill_no
      t.string :particular
      t.integer :quantity
      t.decimal :unit_price, precision: 15, scale: 2
      t.decimal :total_price, precision: 15, scale: 2
      t.string :remarks
    end
  end
end
