class RemoveColumnOrderDetails < ActiveRecord::Migration[4.2]
  def change
    remove_column :order_details, :symbol
  end
end
