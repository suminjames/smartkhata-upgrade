class CreateCustomerLedger < ActiveRecord::Migration[4.2]
  def change
    create_table :customer_ledger do |t|
      t.string :customer_code
      t.string :bill_no
      t.string :settlement_date
      t.string :particulars
      t.string :entered_by
      t.string :entered_date
      t.string :fiscal_year
      t.string :transaction_date
      t.string :dr_amount
      t.string :cr_amount
      t.string :remarks
      t.string :transaction_id
      t.string :slip_no
      t.string :slip_type
      t.string :bill_type
      t.string :settlement_tag
    end
  end
end
