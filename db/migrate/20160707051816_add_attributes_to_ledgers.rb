class AddAttributesToLedgers < ActiveRecord::Migration
  def change
    add_column :ledgers, :opening_balance_org, :decimal, precision: 15, scale: 4, default: 0
    add_column :ledgers, :closing_balance_org, :decimal, precision: 15, scale: 4, default: 0
  end
end
