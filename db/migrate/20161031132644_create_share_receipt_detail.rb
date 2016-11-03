class CreateShareReceiptDetail < ActiveRecord::Migration
  def change
    create_table :share_receipt_detail do |t|
      t.string :receipt_no
      t.string :company_code
      t.integer :received_quantity
      t.integer :rec_certificate_no, limit: 8
      t.integer :rec_kitta_no_from, limit: 8
      t.integer :rec_kitta_no_to, limit: 8
      t.integer :returned_quantity, limit: 8
      t.integer :ret_certificate_no, limit: 8
      t.integer :ret_kitta_no_from, limit: 8
      t.integer :ret_kitta_no_to, limit: 8
      t.date :returned_date
      t.string :returned_by
      t.string :fiscal_year
    end
  end
end
