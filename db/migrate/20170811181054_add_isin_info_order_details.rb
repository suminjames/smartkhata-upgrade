class AddIsinInfoOrderDetails < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :order_details, :isin_infos
  end
end
