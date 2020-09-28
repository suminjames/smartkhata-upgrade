class AddIsinInfoToOrderDetails < ActiveRecord::Migration
  def change
    # since isin info is not
    add_column :order_details, :symbol, :string
  end
end
