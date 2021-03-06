class CreateLedgerDailies < ActiveRecord::Migration[4.2]
  def change
    create_table :ledger_dailies do |t|
      t.date :date
      t.decimal :dr_amount, precision: 15, scale: 4, default: 0.00
      t.decimal :cr_amount, precision: 15, scale: 4, default: 0.00
      t.decimal :opening_blnc, precision: 15, scale: 4, default: 0.00
      t.decimal :closing_blnc, precision: 15, scale: 4, default: 0.00
      t.string :date_bs
      t.integer :fy_code, index: true
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.references :ledger, index: true
      t.integer :branch_id, index: true
      t.timestamps null: false
    end
  end
end
