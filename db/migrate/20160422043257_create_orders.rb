class CreateOrders < ActiveRecord::Migration
  # Sr. No.		Order ID			Symbol		Client Name			Client Code	Price			Quantity		Amount				Pending Quantity	Order Time	Order Type	Order Segment	Order Condition		Order State
  def change
    create_table :orders do |t|
      t.integer :order_number
      t.references :client_account, index: true
      t.integer :fy_code
      t.date :date

      t.timestamps null: false
    end
  end
end
