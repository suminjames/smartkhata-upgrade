class AddIndexToBill < ActiveRecord::Migration
  def change
    add_index :bill, :bill_no
  end
end
