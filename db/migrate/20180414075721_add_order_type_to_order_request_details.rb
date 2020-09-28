class AddOrderTypeToOrderRequestDetails < ActiveRecord::Migration
  def change
    add_column :order_request_details, :order_type, :integer
  end
end
