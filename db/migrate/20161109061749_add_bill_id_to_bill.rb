class AddBillIdToBill < ActiveRecord::Migration
  def change
    add_column :bill, :bill_id, :integer
  end
end
