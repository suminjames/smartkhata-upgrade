class CreateLedgerDailies < ActiveRecord::Migration
  def change
    create_table :ledger_dailies do |t|
      t.date :date
      t.decimal :dr_amount, precision: 15, scale: 4, default: 0.00
      t.decimal :cr_amount, precision: 15, scale: 4, default: 0.00
      t.decimal :opening_blnc, precision: 15, scale: 4, default: 0.00
      t.decimal :closing_blnc, precision: 15, scale: 4, default: 0.00
      t.string :date_bs
      t.references :ledger, index: true
      t.timestamps null: false
    end
  end
end
