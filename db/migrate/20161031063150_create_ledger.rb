class CreateLedger < ActiveRecord::Migration
  def change
    create_table :ledger do |t|
      t.string :transaction_id
      t.string :ac_code
      t.string :sub_code
      t.string :voucher_code
      t.string :voucher_no
      t.string :serial_no
      t.string :particulars
      t.decimal :amount, precision: 15, scale: 4
      t.decimal :nrs_amount, precision: 15, scale: 4
      t.string :transaction_type
      t.date :transaction_date
      t.string :effective_transaction_date
      t.string :bs_date
      t.string :book_code
      t.string :internal_no
      t.string :currency_code
      t.decimal :conversion_rate, precision: 15, scale: 4
      t.string :cost_revenue_code
      t.string :record_deleted
      t.string :cheque_no
      t.string :invoice_no
      t.string :vou_period
      t.string :against_ac_code
      t.string :against_sub_code
      t.string :fiscal_year
      t.string :bill_no
    end
  end
end
