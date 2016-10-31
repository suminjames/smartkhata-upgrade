class CreateCustomerLedger < ActiveRecord::Migration
  def change
    create_table :customer_ledger do |t|
      t.string :customer_code
      t.string :bill_no
      t.date :settlement_date
      t.string :particulars
      t.string :entered_by
      t.date :entered_date
      t.string :fiscal_year
      t.date :transaction_date
      t.decimal :dr_amount, precision: 15, scale: 4
      t.decimal :cr_amount, precision: 15, scale: 4
      t.string :remarks
      t.string :transaction_id
      t.integer :slip_no
      t.string :slip_type
      t.string :bill_type
      t.string :settlement_tag
    end
  end
end
