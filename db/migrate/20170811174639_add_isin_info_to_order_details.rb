class AddIsinInfoToOrderDetails < ActiveRecord::Migration[4.2]
  def change
    # since isin info is not
    add_column :order_details, :symbol, :string
  end
end
