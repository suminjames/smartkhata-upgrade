class CreateOrderRequests < ActiveRecord::Migration
  def change
    create_table :order_requests do |t|
      t.string :date_bs

      t.timestamps null: false
    end
  end
end
