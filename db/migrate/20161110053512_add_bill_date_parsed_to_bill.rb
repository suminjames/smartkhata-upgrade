class AddBillDateParsedToBill < ActiveRecord::Migration
  def change
    add_column :bill, :bill_date_parsed, :date
  end
end
