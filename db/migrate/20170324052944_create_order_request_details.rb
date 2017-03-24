class CreateOrderRequestDetails < ActiveRecord::Migration
  def change
    create_table :order_request_details do |t|
      t.integer :quantity
      t.integer :rate
      t.integer :status
      t.integer :isin_info, index: true
      t.references :order_request, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
