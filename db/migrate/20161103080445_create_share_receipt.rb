class CreateShareReceipt < ActiveRecord::Migration[4.2]
  def change
    create_table :share_receipt do |t|
      t.string :receipt_no
      t.string :received_date
      t.string :customer_code
      t.string :received_by
      t.string :fiscal_year
      t.string :remarks
    end
  end
end
