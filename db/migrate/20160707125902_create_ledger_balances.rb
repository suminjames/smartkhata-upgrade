class CreateLedgerBalances < ActiveRecord::Migration
  def change
    create_table :ledger_balances do |t|
      t.decimal :opening_blnc, precision: 15, scale: 4, default: 0.00
      t.decimal :closing_blnc, precision: 15, scale: 4, default: 0.00
      t.integer :fy_code, index: true
      t.integer :branch_id, index: true
      t.integer :creator_id
      t.integer :updater_id
      t.references :ledger, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
