class CreateSupplierBillDetail < ActiveRecord::Migration
  def change
    create_table :supplier_bill_detail do |t|
      t.string :bill_no
      t.string :particular
      t.string :quantity
      t.string :unit_price
      t.string :total_price
      t.string :remarks
    end
  end
end
