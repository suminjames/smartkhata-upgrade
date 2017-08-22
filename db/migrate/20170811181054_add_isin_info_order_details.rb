class AddIsinInfoOrderDetails < ActiveRecord::Migration
  def change
    add_foreign_key :order_details, :isin_infos
  end
end
