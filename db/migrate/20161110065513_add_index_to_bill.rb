class AddIndexToBill < ActiveRecord::Migration[4.2]
  def change
    add_index :bill, :bill_no
  end
end
