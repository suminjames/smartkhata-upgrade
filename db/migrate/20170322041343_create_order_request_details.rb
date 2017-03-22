class CreateOrderRequestDetails < ActiveRecord::Migration
  def change
    create_table :order_request_details do |t|
      t.integer :quantity
      t.integer :rate
      t.integer :status
      t.references :isin_info, index: true, foreign_key: true
      t.references :order_request, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
