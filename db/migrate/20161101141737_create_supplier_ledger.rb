class CreateSupplierLedger < ActiveRecord::Migration
  def change
    create_table :supplier_ledger do |t|
      t.string :supplier_id
      t.string :bill_no
      t.date :settlement_date
      t.string :particulars
      t.string :entered_by
      t.date :entered_date
      t.string :fiscal_year
      t.date :transaction_date
      t.decimal :dr_amount, precision: 15, scale: 2
      t.decimal :cr_amount, precision: 15, scale: 2
      t.integer :transaction_id, limit: 8
      t.string :slip_no
      t.string :slip_type
      t.string :settlement_tag
      t.string :remarks
      t.integer :quantity
    end
  end
end
