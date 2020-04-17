class AddBillIdToBill < ActiveRecord::Migration[4.2]
  def change
    add_column :bill, :bill_id, :integer
  end
end
