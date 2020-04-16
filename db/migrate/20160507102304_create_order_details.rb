class CreateOrderDetails < ActiveRecord::Migration[4.2]
  def change
    create_table :order_details do |t|
      t.references :order, index: true
      t.string :order_nepse_id #Stored in string not integer because of its length. This identifier is extracted from order xls file provided by nepse.
      t.references :isin_info, index: true
      t.decimal :price
      t.integer :quantity
      t.decimal :amount
      t.integer :pending_quantity
      t.integer :typee # type is a reserved word
      t.integer :segment
      t.integer :condition
      t.integer :state
      t.datetime :date_time

      t.timestamps null: false
    end
  end
end
