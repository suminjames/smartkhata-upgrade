class CreateShareReceiptDetail < ActiveRecord::Migration
  def change
    create_table :share_receipt_detail do |t|
      t.string :receipt_no
      t.string :company_code
      t.string :received_quantity
      t.string :rec_certificate_no
      t.string :rec_kitta_no_from
      t.string :rec_kitta_no_to
      t.string :returned_quantity
      t.string :ret_certificate_no
      t.string :ret_kitta_no_from
      t.string :ret_kitta_no_to
      t.string :returned_date
      t.string :returned_by
      t.string :fiscal_year
    end
  end
end
