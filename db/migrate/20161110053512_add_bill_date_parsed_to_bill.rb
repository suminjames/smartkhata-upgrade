class AddBillDateParsedToBill < ActiveRecord::Migration[4.2]
  def change
    add_column :bill, :bill_date_parsed, :date
  end
end
