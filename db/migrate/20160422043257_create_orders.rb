class CreateOrders < ActiveRecord::Migration
  # Sr. No.		Order ID			Symbol		Client Name			Client Code	Price			Quantity		Amount				Pending Quantity	Order Time	Order Type	Order Segment	Order Condition		Order State
  def change
    create_table :orders do |t|
      t.string:order_id #Stored in string not integer because of its length
      t.references :isin_info, index: true
      # t.string :symbol
      t.references :client_account, index: true
      # t.string :client_name
      # t.string :client_code
      t.decimal :price
      t.integer :quantity
      t.decimal :amount
      t.integer :pending_quantity
      t.datetime :order_date_time
      t.integer :order_type 
      t.integer :order_segment 
      t.integer :order_condition
      t.integer :order_state

      t.timestamps null: false
    end
  end
end
