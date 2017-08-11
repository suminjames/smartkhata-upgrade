class RemoveColumnOrderDetails < ActiveRecord::Migration
  def change
    remove_column :order_details, :symbol
  end
end
