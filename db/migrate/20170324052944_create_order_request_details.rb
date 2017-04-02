class CreateOrderRequestDetails < ActiveRecord::Migration
  def change
    create_table :order_request_details do |t|
      t.integer :quantity
      t.integer :rate
      t.integer :status, default: 0
      t.integer :isin_info_id, index: true
      t.references :order_request, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
