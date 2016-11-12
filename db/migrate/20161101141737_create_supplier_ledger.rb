class CreateSupplierLedger < ActiveRecord::Migration
  def change
    create_table :supplier_ledger do |t|
      t.string :supplier_id
      t.string :bill_no
      t.string :settlement_date
      t.string :particulars
      t.string :entered_by
      t.string :entered_date
      t.string :fiscal_year
      t.string :transaction_date
      t.string :dr_amount
      t.string :cr_amount
      t.string :transaction_id
      t.string :slip_no
      t.string :slip_type
      t.string :settlement_tag
      t.string :remarks
      t.string :quantity
    end
  end
end
