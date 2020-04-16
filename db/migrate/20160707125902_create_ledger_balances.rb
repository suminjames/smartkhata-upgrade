class CreateLedgerBalances < ActiveRecord::Migration[4.2]
  def change
    create_table :ledger_balances do |t|
      t.decimal :opening_balance, precision: 15, scale: 4, default: 0.00
      t.decimal :closing_balance, precision: 15, scale: 4, default: 0.00
      t.decimal :dr_amount, precision: 15, scale: 4, default: 0.00
      t.decimal :cr_amount, precision: 15, scale: 4, default: 0.00
      t.integer :fy_code, index: true
      t.integer :branch_id, index: true
      t.integer :creator_id
      t.integer :updater_id
      t.references :ledger, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
