class AddIndexToBillDetail < ActiveRecord::Migration
  def change
    add_index :bill_detail, :bill_no
    add_index :bill_detail, :transaction_no
    add_index :bill_detail, :transaction_type
  end
end
