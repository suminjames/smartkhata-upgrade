class CreateOrderRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :order_requests do |t|
      t.references :client_account, index: true, foreign_key: true
      t.string :date_bs

      t.timestamps null: false
    end
  end
end
