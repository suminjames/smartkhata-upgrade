class AddAttributesToLedgers < ActiveRecord::Migration[4.2]
  def change
    add_column :ledgers, :opening_balance_org, :decimal, precision: 15, scale: 4, default: 0
    add_column :ledgers, :closing_balance_org, :decimal, precision: 15, scale: 4, default: 0
  end
end
