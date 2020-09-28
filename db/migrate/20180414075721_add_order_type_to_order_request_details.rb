class AddOrderTypeToOrderRequestDetails < ActiveRecord::Migration[4.2]
  def change
    add_column :order_request_details, :order_type, :integer
  end
end
