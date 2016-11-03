class CreateSupplierBill < ActiveRecord::Migration
  def change
    create_table :supplier_bill do |t|
      t.string :bill_no
      t.date :bill_date
      t.string :manual_no
      t.string :supplier_id
      t.string :prepare_by
      t.string :fiscal_year
      t.string :voucher_no
      t.date :prepared_on
      t.string :voucher_code
      t.string :ac_code
    end
  end
end
